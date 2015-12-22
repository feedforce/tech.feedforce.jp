---
title: API Gateway + LambdaでSlackボットを作ってみた
date: 2015-12-23 0:00 JST
authors: otofu_square
tags: aws
---

寒くなってきましたが暑がりなのでまだ上着はあまり出番がありません、内定者のお豆腐です。
今回はエンジニア内定者ブログ第2弾として、API Gateway + Lambdaを使ってサーバーレスなSlackボットを実装してみる、というお題で記事を書いてみました。

<!--more-->

## 目的

昨今、サーバーレスアーキテクチャと呼ばれる技術分野が注目されており、それを実現する基盤としてAmazon Web Service（以下AWS）のLambdaが注目されています。
今年10月にAWSが提供するAPI GatewayがTokyoリージョンでも使用が可能になり、API GatewayとLambdaを組み合わせたアプリケーションの開発がより手軽に行えるようになりました。

そんな中、弊社ではまだAPI Gateway, Lambdaを採用したサービスやノウハウがありませんでした。
そこで今回、実際に上記2つの技術を使ってサンプルを作ることで今後業務や社内ツールでも使えるかどうか確かめようということで、Slackボットを作ってみることにしました。

## やりたいこと

SlackのOutgoing Webhocksを使ってAPI（API Gateway + Lambda）を叩いて、登録したLGTM画像のURLを呼び出せるボットを作ります。
画像のURLは今回実装するAPIを通してAWSで提供されているDynamoDBに保存します。
呼び出しの際はDynamoDBに保存した値を取得してSlack側に返します。

## 今回使ったサービス

### API Gateway

API Gatewayとは、 APIの作成、保守、監視、保護が行えるAWSのサービスです。
このサービスを使うことで、既存のAPIロジックやAWS Lambdaのファンクションを利用したRESTfulなAPIを公開することができます。
API Gatewayは今回のボットを作る上で、Slackが送信したデータを受け取りLambda側に受け渡す役割を担います。
料金も非常に低価格で、個人利用や悪意のある大量アクセスがない限りはほぼ無料同然の価格で使用することができます。

- 100 万回の API 呼び出しの受信につき 4.25 USD
- データ転送費用は最初の10TBにつき 0.14 USD/GB（10TB以降はこれよりGB当たりの料金が安くなる）

参考: [Amazon API Gateway - 料金](https://aws.amazon.com/jp/api-gateway/pricing/)

### Lambda

LambdaもAWSが提供しているサービスの一つで、クラウド上でコードが実行できる環境を提供するサービスです。
自前でコードを実行可能な環境をWeb上に構築しようとすると、そのためのサーバを用意したり管理する必要がありますが、Lambdaを使うことでユーザはサーバを用意することなくコードを実行する環境を手に入れることができます。
つまり先ほど紹介したサーバーレスアーキテクチャを構成するのにもってこいなサービスなわけです。
実行可能なプログラミング言語は2015年12月現在、Java 8, Node.js(v0.10.36), Python(2.7)の3つになります。

Lambdaは他のAWSサービスと異なり、1年間の無料期間を過ぎた後であっても下記の無料分が与えられます。
個人利用や小規模なサービスであれば十分なほどの無料枠だといえるでしょう。
夢が広がりますね！

- 1 か月に 1,000,000 件の無料リクエスト
- 400,000 GB/秒のコンピューティング時間が無料

上記を超える利用に関しては下記の料金がかかります。

- メモリ量により異なるが、最小構成（メモリ128MB）の場合は0.00000208USD/秒
- 1,000,000件のリクエストにつき 0.20 USD

料金の例がAWSの公式HPで紹介されていますので、更に気になる方はそちらを見てみると良いかもしれません。

参考: [AWS Lambda - 料金](https://aws.amazon.com/jp/lambda/pricing/)

### DynamoDB

DynamoDBは、AWSが提供するスキーマレスなNoSQLデータベースサービスです。
データベースサーバの構成やセキュリティ、管理などは全てDynamoDB側で行ってくれるため、フルマネージドなデータベースとして利用することができます。
AWS-SDKを使ってLambdaのコードから簡単にデータの登録、取得が行えるので、今回画像URLの保存先として採用しました。

こちらも1年間の無料枠が設定されているので、個人利用の範囲であればまず料金は発生しないと思って良いでしょう。
料金形態は少々複雑になっているので、気になる方は下記の公式ページをご覧ください！

参考: [AWS DynamoDB - 料金](https://aws.amazon.com/jp/dynamodb/pricing/)

## やったこと

### 実装の流れ

今回のボット作りは以下の流れで行いました。

- 1. ボットをNode.jsで実装
- 2. SlackのOutgoing Webhocksの設定
- 3. API Gatewayの設定
- 4. Lambdaの設定

### 1. ボットの中身の実装

#### 実装について

今回作成したボットは次のような構造になっています。
ソースコードはgithubのレポジトリで公開しているので、気になった方はそちらも確認してみてください！
[otofu-square/lgtm_bot - github](https://github.com/otofu-square/lgtm_bot)

```
index.js
node_modules
└ aws-sdk-promise
lib
├ requestHandler.js
├ ping.js
├ help.js
├ get.js
├ getAll.js
├ add.js
└ auth.js
```

Lambda内では初めに[index.js](https://github.com/otofu-square/lgtm_bot/tree/master/index.js)が読み込まれ、API Gatewayが受け取ったJSONのデータが渡ってきます。
Slack側から送られてきたテキストデータを[index.js](https://github.com/otofu-square/lgtm_bot/tree/master/index.js)内でコマンドとオプションに分割して、[lib/requestHandler.js](https://github.com/otofu-square/lgtm_bot/tree/master/lib/requestHandler.js)で各処理に振り分けています。

#### ローカル環境でのテスト

Lambda上でもテストは可能なのですが、今回は実行時にメッセージが送られてしまったりしてあまり気軽にデバッグができません。
そこでローカルでLambdaの動作確認を行える[lambda-local](https://www.npmjs.com/package/lambda-local)という便利なnpmがあります。
Lambdaにインプットする情報を設定することで、あたかもLambdaを実際に動かしているような形でテストを行うことができます。

#### 各コマンドの実装

今回ボットに実装する機能は下記5つになります。

- pingコマンド
- helpコマンド
- add コマンド
- listコマンド
- showコマンド

ここでは、簡単に各コマンドについてご紹介します。

##### pingコマンド

pingコマンドは、単純に`pong`という文字列を返すだけのシンプルな機能です。
ボットと通信できているかどうか確認する時に使用することを想定して実装しました。

```
lgtm: ping

> pong
```

[lgtm_bot/lib/ping.js](https://github.com/otofu-square/lgtm_bot/tree/master/lib/ping.js)

##### helpコマンド

ボットのコマンドの一覧と、その使い方をメッセージとして返す機能です。
オプションの渡し方やコマンド名を参照することができます。

```
lgtm: help

> lgtm: ping
> lgtm: list
> lgtm: add <name> <url>
> lgtm: show <name>
```

[lgtm_bot/lib/help.js](https://github.com/otofu-square/lgtm_bot/tree/master/lib/help.js)

##### add コマンド

画像のURLを登録する機能です。
既に同じ`name`の画像URLが登録されている場合は上書きされます。

```
lgtm: add test http://image.com/lgtm.jpg

> Success.
> ID : test,
> URL: http://image.com/lgtm.jpg
```

[lgtm_bot/lib/add.js](https://github.com/otofu-square/lgtm_bot/tree/master/lib/add.js)

##### listコマンド

現在登録されている画像URLの`name`値の一覧を返す機能です。

```
lgtm: list

> test
> test1
> test2
...

```

[lgtm_bot/lib/getAll.js](https://github.com/otofu-square/lgtm_bot/tree/master/lib/getAll.js)

##### showコマンド

指定した`name`の画像URLを呼び出します。

```
lgtm: show test

> http://image.com/lgtm.jpg
```

[lgtm_bot/lib/get.js](https://github.com/otofu-square/lgtm_bot/tree/master/lib/get.js)

### 2. Slack

#### Outgoing Webhocksの設定

Slack上の任意のPublicチャンネルに `Outgoing Webhocks` というインテグレーションを設定することで、チャンネル内の特定の発言をトリガにして外部APIを叩くことができます。

Outgoing Webhocksを設定すると、設定で指定したAPIに対してSlack側からContent-Typeが`application/x-www-form-urlencoded（フォーム送信データ）`のデータが送信されます。
送られてくるパラメータは以下の通りとなります。

```
token=APIトークン
team_id=チームID
team_domain=チームドメイン
channel_id=チャンネルID
channel_name=チャンネル名
timestamp=実行時のタイムスタンプ
user_id=トリガワードを発したユーザID
user_name=トリガワードを発したユーザ名
text=トリガワードが含まれるメッセージ本文
trigger_word=トリガワード
```

今回はSlack側から受け取った`text`データをLambda側で分析して、その`text`データに応じた処理をするよう実装しました。

参考: [Slack API - Outgoing Webhocks](https://api.slack.com/outgoing-webhooks)

### 3. API Gateway

#### 初期設定

初期設定に関しては[AWS公式の開発者ガイド](http://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/setting-up.html)が非常に分かりやすいのでそちらにお任せしたいと思います…！
実際にガイド通りに操作することで問題なくAPI Gatewayを設定することができました。
ただ、マッピングテンプレートに関しては少々難儀したため、以下でご紹介します。

#### マッピングテンプレートの作成

Slack側からはContent-Typeが`application/x-www-form-urlencoded（フォーム送信データ）`が送られてきますが、Lambda側で受け取れるデータはJSONです。よって、API GatewayでSlack側から送られてきたデータを`application/json（JSONデータ）`に変換してあげる必要があります。

API Gatewayには `Integration Request` , `Integration Response` という設定で、APIへ送られてきたデータやAPIから送るデータを、API側の処理の前段階/後段階で最適な形に変換することができます。
今回はSlack側からLambda側に送られてくる `application/x-www-form-urlencoded` のデータをJSONに変換するため、 `Integration Request` に以下のマッピングテンプレートを実装しました。
実装言語は `VTL(Velocity Template Language)` と呼ばれる言語を用います。[^1]

簡単に説明すると、`##`以下がコメント、`#`が制御ロジックとなり、`#`が行頭に無い部分は実際に出力されるデータそのものとなります。

```
## &区切りでPOSTされてきたデータを分割する
#set($httpPost = $input.path('$').split("&"))

## 出力されるJSONデータの生成
{
#foreach( $keyValue in $httpPost )
 ## "key=value"というデータをkeyとvalueに分ける
 #set($data = $keyValue.split("="))
 ## JSONのフォーマットに整形する（まだ走査するデータがあれば","を挿入する）
 "$data[0]" : "$data[1]"#if( $foreach.hasNext ),#end
#end
}
```

### 4. Lambda

#### ソースコードのアップロード

実装したボットのソースコードをzipで圧縮してLambdaにアップロードすることで、実際にLambda上で実行することが可能になります。
zipで圧縮する際はソースが入っているディレクトリをまとめてzipにするのではなく、下記のように個別でzipにする必要があります。

`$ zip -r lambda.zip index.js node_modules lib`

圧縮が終わったら、zipファイルをLambdaにアップロードします。
AWSコンソールのLambdaの管理画面からも可能ですし、`aws-cli`がインストールされてれば下記コマンドからでもアップロード可能です。

`$ aws lambda update-function-code --function-name lgtm_bot --zip-file lambda.zip`

特に問題がなければ、アップロードした段階で実装完了となります。
試しにSlackから`lgtm: ping`や`lgtm: help`と打ってみて、リプライが返ってくれば問題ないと思います！

Lambdaの管理画面の操作や設定に関しては下記の公式ガイドが参考になりました。

参考: [AWS Lambda - Developer Guide](http://docs.aws.amazon.com/ja_jp/lambda/latest/dg/welcome.html)

## まとめ

今回はなんとか無事にAPI Gateway, Lambdaを使ってSlackボットを実装することができました！
自前のAPIサーバーやドメインを取得することなく、非常に手軽にアプリを実装できて感動しました。
今回のボットは、サーバーレスアーキテクチャの例としてはシンプルなものでしたが、もっと複雑なアプリケーションも作れてしまいそうな気配があります。
今後ともAPI Gateway + Lambdaの展開を追いつつ、いつかこの技術を弊社のサービスに何らかの形で応用する場面がないか探っていきたいと思います。

[^1]: [Apache Project](http://www.apache.org)によって開発された[Velocity](http://velocity.apache.org)と呼ばれるJavaによる実装のテンプレートエンジンで用いる言語。
