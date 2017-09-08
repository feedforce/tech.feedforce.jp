---
title: DynamoDB を Rails で使えるようにするためのあれこれ
date: 2017-09-11 00:00 JST
authors: ryosuke_sato
tags: ruby, aws
---

初めまして。バックエンドエンジニアの佐藤と申します。
弊社プロダクト [ソーシャルPLUS](https://socialplus.jp/) では [Amazon DynamoDB](https://aws.amazon.com/jp/dynamodb/) を使用しております。しかし、導入手順が思ったより煩雑でハマった点も多かったため、備忘録として記事にしておこうと思います。

<!--more-->

## どうやるの？

### 開発環境に Docker を使用している場合の設定

DynamoDB のローカルでの開発環境には AWS が公開している [DynamoDB Local](https://aws.amazon.com/jp/blogs/aws/dynamodb-local-for-desktop-development/) があります。これを利用しても良いのですが、ソーシャルPLUSチームでは開発環境に Docker を採用しているので、 DynamoDB の Docker イメージを利用します。
ここでは [deangiberson/aws-dynamodb-local](https://hub.docker.com/r/deangiberson/aws-dynamodb-local/) という Docker イメージを使います。これは DynamoDB Local を個人で Docker イメージにしたものを公開されているようです。この記事では触れませんが、 [atlassianlabs/localstack ](https://hub.docker.com/r/atlassianlabs/localstack/) を利用する、という方法もあります。
ちなみに後述する CircleCI での設定でも Docker イメージの話は出てきます。

`docker-compose.yml` に以下の設定を追加します。

```yaml
msgdynamodb:
  image: deangiberson/aws-dynamodb-local
  ports:
    - 8001:8000
  environment:
    DEFAULT_REGION: ap-northeast-1
```

今回は同一の Docker ネットワーク内で複数の DynamoDB を利用しているため、`ports` でポート番号を変えていますが、単一でしか利用していない場合は設定不要になります。

### Rails アプリケーションの設定

#### Dynamoid を使用するための準備

ActiveRecord は MySQL など RDB の O/R マッパーなので、 DynamoDB の場合は `dynamoid` という O/Rマッパーを使用します。Gemfile に以下のコードを追加します。

```rb
gem 'dynamoid', '~> 1'
```

`aws-sdk` の v2 が必要になってくるのでご注意ください。ちなみに `aws-sdk` は v1 と v2 が共存できるので安心です。

`config/initializers/dynamoid.rb` を作成し、以下のように記述します。

```rb
# frozen_string_literal: true
# see: https://github.com/Dynamoid/Dynamoid#prerequisities
Dynamoid.configure do |config|
  config.region = 'ap-northeast-1'
  config.endpoint = Settings.aws.dynamodb.endpoint
  config.namespace = Settings.aws.dynamodb.namespace
  config.read_capacity = Settings.aws.dynamodb.read_capacity
  config.write_capacity = Settings.aws.dynamodb.write_capacity
end
```

設定値の詳細は Rails の Config を利用して `config/settings/xxx.yml` へ記述しています。ここでは `development` と `test` の例を記載します。

config/settings/development.yml

```yaml
aws:
  dynamodb:
    namespace: development
    endpoint: http://msgdynamodb:8000
    read_capacity: 5
    write_capacity: 5
```

config/settings/test.yml

```yaml
aws:
  dynamodb:
    namespace: test
    endpoint: <%= ENV.fetch('CIRCLECI_DYNAMODB_ENDPOINT', 'http://msgdynamodb:8000') %>
    read_capacity: 5
    write_capacity: 5
```

`read_capacity` と `write_capacity` は読み書きの制限値になります。この値によって課金額が変化するので、本番環境以外は少なめの値に設定しておくと良いと思います。ちなみに最近では [DynamoDB が Auto Scaling に対応](https://aws.amazon.com/jp/blogs/news/new-auto-scaling-for-amazon-dynamodb/) したので、アクセスが増えた時に自動的にスケールするようにできるようになりました。しかし、 Auto Scaling の設定は Dynamoid からは設定できないようなので、 AWS のコンソールから手動で設定する必要があります。

#### 実際に動かしてからやること

Model の実装については `dynamoid` の [GitHub](https://github.com/Dynamoid/Dynamoid) を見て頂くとして、実際に動かしてからのことを書きます。`dynamoid` は実行時に対応するテーブルが存在していないと、自動的に AWS 上でテーブルの作成までやってくれます。ですが、この時に例外が発生してしまうので、本番への適用時に一度試験的に動作させるなどが必要になってくるかと思います。AWS のマネジメントコンソールにも、エラーとして記録が残りますが、原因は同様です。
テーブルが作成されたら、コンソールから名前などが適切であるか確認しましょう。そして、前述のように **Auto Scaling の設定** も忘れずにやりましょう。

### Rspec の設定

#### DynamoDB のデータをリセットする機能を追加する

ActiveRecord であれば `use_transactional_fixtures = true` と記述すれば、テスト毎にテーブルの内容がリセットされるのですが、Dynamoid においては自前でリセットの仕組みを用意する必要があります。

https://github.com/Dynamoid/Dynamoid#test-environment を参考に、`spec/support/dynamoid_reset.rb` に以下のような処理を記述します。

spec/support/dynamoid_reset.rb

```rb
# frozen_string_literal: true
# see: https://github.com/Dynamoid/Dynamoid#test-environment
module DynamoidReset
  def self.all
    Dynamoid.adapter.list_tables.each do |table|
      if table.match?(/^#{Dynamoid::Config.namespace}/)
        Dynamoid.adapter.delete_table(table)
      end
    end
    Dynamoid.adapter.tables.clear
    Dynamoid.included_models.each(&:create_table)
  end
end
```

そして `spec/rails_helper.rb` に以下の処理を追記します。

```rb
# see: https://github.com/Dynamoid/Dynamoid#test-environment
config.before :each, dynamodb: true do
  DynamoidReset.all
end
```

このリセット処理は意外に重たい処理なので、実行するのは dynamodb に関連するテストのみにした方が良いかと思います。 `dynamodb: true` というオプションを付けておくと、以下のようなテストの場合のみ、この初期化処理が有効になります。

```rb
RSpec.describe Hoge, dynamodb: true do
  # このブロック内のテスト全てに `dynamodb: true` が適用されます。
end

RSpec.describe Fuga do
  it 'foo', dynamodb: true do
    # `it` 毎に設定することもできます。
  end
end
```

#### WebMock を使用している場合

多くの Rspec で外部APIへの接続をモック化する `WebMock` を利用していると思います。
そのままだとローカルの DynamoDB に接続できないので、`spec/rails_helper.rb` に以下の処理を追記します。

```rb
config.before :suite do
  WebMock.disable_net_connect!(allow: Settings.aws.dynamodb.endpoint)
end
```

#### AWS SDK で `stub_responses: true` を適用している場合

AWS SDK v2 では、`Aws.config[:stub_responses] = true` と設定することで、SDK 経由での AWS 利用をスタブ化することができます。しかしそのままだとローカルで建てた DynamoDB へのアクセスまでスタブ化されてしまうので、以下の記述が必要です。

```rb
config.before :suite do
  Aws.config[:stub_responses] = true
  Aws.config[:dynamodb] = { stub_responses: false } # <= これ！
end
```

こういう記述が出来ることを調べるのに随分苦労しました。。

### CircleCI 2.0 での設定

CircleCI 2.0 から Docker イメージを使用するようになったことは周知かと思います。Docker の設定の項でも使用した Docker イメージを設定していきます。`.circleci/config.yml` に以下の設定を追加します。

```diff
version: 2
  jobs:
    build:
      docker: &docker
        - image: circleci/ruby:2.4.1
          environment:
            TZ: /usr/share/zoneinfo/Asia/Tokyo
            RAILS_ENV: test
+           CIRCLECI_DYNAMODB_ENDPOINT: http://localhost:8000
        - image: circleci/mysql:5.7
+       - image: deangiberson/aws-dynamodb-local
+         environment:
+           SERVICES: dynamodb
+         entrypoint: ['/usr/bin/java', '-Xms1G', '-Xmx1G', '-Djava.library.path=.', '-jar', 'DynamoDBLocal.jar', '-dbPath', '/var/dynamodb_local', '-port', '8000']
```

重要なのが `entrypoint: ['/usr/bin/java', '-Xms1G', '-Xmx1G'...` の部分でして、これは [Java プロセスのメモリー占有領域を制限するためのオプション](http://docs.oracle.com/cd/E22646_01/doc.40/b61439/tune_footprint.htm) です。 `-Xms1G`, `-Xmx1G` とすると、 Java のメモリ領域を 1 GByte に制限してくれます。
この設定が無いと、 DynamoDB Local のメモリ使用量が爆発して CircleCI でのテストが死にます。。
`atlassianlabs/localstack` を使用していた時も同様でした。

これも原因を調べるのに随分苦労したので、皆さんは罠にはまらないように気を付けてください。

## 終わりに

以上の設定で Rails で DynamoDB が利用できるようなったかと思います。
