---
title: Slack上のrubotyに登録したジョブを編集する
date: 2015-09-29 17:18 JST
authors: otofu_square
tags:
---

こんにちは。2016年卒内定者のotofu-squareです。社内ではお豆腐先生と呼ばれています。
現在内定者インターンの活動の中で、技術ブログを執筆してみる、という試みがなされています。
そこで今回は、弊社が利用するSlack上で動くrubotyボットに登録されたジョブをまとめて編集する方法をご紹介します。

<!--more-->

## 背景

弊社では社内SNSとしてSlackを利用しており、その中にフィードくんというBOTが住んでいます。

![Slack上に住んでいる弊社マスコットキャラクター「フィードくん」](/images/2015/09/feedkun.png)

Slack上のフィードくんは[ruboty](https://github.com/r7kamura/ruboty)というチャットボットフレームワークで実装されheroku上で動作しており、[ruboty-cron](https://github.com/r7kamura/ruboty-cron)というプラグインを利用して必要に応じてジョブを登録して発言してもらっています。以前ruboty-cronのアップデートが入った際に、登録してあるジョブのフォーマットを全て変更する必要がありました。変更に当たってSlack上からフィードくんに登録されているジョブの一覧を参照したのですが、どのチャンネルで登録されたジョブか分からず、ジョブの再登録に当たっては結局登録した人の記憶頼りとなってしまいました。今回はそのような場合に、登録したジョブを取得してまとめて編集する方法をご紹介します。

## フィードくんの生活環境（動作環境）

ここでは、フィードくんがどのように実装され、どんな環境で動作しているかご紹介します。
フィードくんは、前述の通りrubotyで実装され、

### ruboty

（WIP）rubotyの説明
弊社で使っているrubotyはgithub上に[feedforce-ruboty](https://github.com/feedforce/feedforce-ruboty)として公開されているので、どんなプラグインを使っているのか興味をお持ちの方は是非見てみてくださいね！

### heroku

（WIP）herokuの簡単な説明

### redis(Redis To Go)

（WIP）redisとRedis To Goの説明

## フィードくんの脳みそを解剖する（ジョブの取得）

それでは実際に、フィードくんの脳みそ（Redis To Go）から登録されているジョブを取り出してみましょう。弊社では開発言語としてrubyが使われることが多いので、今回紹介するスクリプトでもrubyを使用しています。

### アクセス情報をherokuから取得する

まずrubotyをデプロイしているherokuにアクセスして、Redis To Goのアクセス情報を取得します。アクセス情報はheroku上の環境変数に保存されているので、ターミナルからherokuにアクセスして環境変数を参照します。ターミナルからherokuを操作するには[Heroku Toolbelt](https://toolbelt.heroku.com)のインストールが必要なのでご注意ください。それでは実際にherokuにログインして、herokuのコンソールを立ち上げてみましょう。

```
$ heroku login
$ heroku run console --app アプリ名
```

コマンドを実行すると、次のような表示になります。
デフォルトではheroku上でirbが立ち上がるようになっています。

```
Running console on アプリ名... up, run.xxxx
irb(main):001:0>
```

環境変数は `ENV` 変数に格納されているので、読みやすいように`pp`メソッドで参照してみましょう。
ENVの中に `REDISTOGO_URL` というキーがあるはずです。

```terminal
irb(main):001:0> require 'pp'
=> true
irb(main):002:0> pp ENV
{"..."=>"..."
 ...
 ...
 "REDISTOGO_URL"=>"redis://redistogo:..."
 ...
 ...
}
```

この値がRedis To Goにアクセスするために必要な情報となりますので、控えておきましょう。

### Redis To Goにアクセスする

それではrubyを使ってredisにアクセスしてみましょう！
今回はredisに簡単にアクセスするために、[redis-rb](https://github.com/redis/redis-rb)というgemを使います。

```ruby
require 'redis'

# REDISTOGO_URLから取得した値をそのままコピペする
url = "redis://redistogo:.../"

redis = Redis.new(:url => url)
```

url変数には、先ほど取得した`REDISTOGO_URL`の値をそのままコピペします。
上のスクリプトを実行するとredisというインスタンスが作成されます。
このインスタンスを通して、接続先のredisで様々な操作を行うことができます。

### データを取得する

それではredisインスタンスからgetメソッドを呼び出して、登録されているジョブを取得しましょう。
rubotyはデフォルトで`ruboty:brain`というキーにデータを保存するよう設定されています。

```ruby
raw_data = redis.get("ruboty:brain")
```

raw_data変数に取得したデータが格納されます。

### 取得したデータをオブジェクトに変換する

rubotyはジョブを登録するとき、ジョブのオブジェクト情報を、[Marshalモジュール](http://rurema.clear-code.com/2.2.0/class/Marshal.html)のdumpメソッドでテキスト情報に変換してredisに保存しています。
なので今回redisから取得したデータは`Marshal.load`で元のオブジェクトに戻してあげる必要があります。

```ruby
Marshal.load(raw_data)
```

上記スクリプトを実行すると、登録したジョブがハッシュとして取得できます。

## フィードくんの記憶を改竄する（ジョブの編集）

フィードくんの脳みそから無事ジョブデータを取得することができました。
それでは次に、取得したジョブデータを編集してフィードくんの脳みそに戻す方法をご紹介しましょう。

### ジョブデータの構造

（WIP）

### ジョブを編集する

（WIP）

## まとめ

まとめ

## 参考記事

参考記事
