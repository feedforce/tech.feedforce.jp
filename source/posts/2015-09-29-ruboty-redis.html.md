---
title: Slack上のrubotyに登録したジョブを編集する
date: 2015-09-29 17:18 JST
authors: otofu_square
tags: ruby
---

こんにちは。2016年卒内定者のotofu_squareです。社内ではお豆腐先生と呼ばれています。

今参加させていただいている内定者インターンの活動の一環として、技術ブログの執筆に加わってみよう、ということになりました。
そこで今回は、弊社が利用するSlack上で動くruboty ボット『feedくん』と、そのボットに登録されたジョブをまとめて編集する方法についてご紹介します。

<!--more-->

## feedくんとは

feedくんは、feedforceの公式ゆるキャラ（？）で、[弊社ホームページ](https://www.feedforce.jp)上でも所々に出てきては見ている人の心を和ませてくれる憎めないヤツです。
弊社では社内のコミュニケーションツールとしてSlackを利用しており、その中にfeedくんがボットとして住んでいます。

<img style="display: block; margin-left: auto; margin-right:auto;" src="/images/2015/09/feedkun.png" alt="Slack上に住んでいる弊社マスコットキャラクター「feedくん」"/>

feedくんは[ruboty](https://github.com/r7kamura/ruboty)というチャットボットフレームワークで実装されHeroku上で動作しており、[ruboty-cron](https://github.com/r7kamura/ruboty-cron)というプラグインを利用して必要に応じてジョブを登録して発言してもらっています。
その他にも、画像を検索してくれたり、雑談に付き合ってくれたりもします。
最近では、技術書管理に[ruboty-can\_i_borrow](https://github.com/rike422/ruboty-can_i_borrow)を使ってみよう…！という動きもあるようです。
また、弊社エンジニアの[kano-e](author/e-takano)さんが以前実装した、[東京ドームのイベントをお知らせしてくれるセバスチャン](sebastian.html)の機能もfeedくんに移植されています。

## feedくんの生活環境（動作環境）

それでは本題に入る前に、feedくんがどのように実装され、どんな環境で動作しているかご紹介します。

### ruboty

前述の通り、feedくんはrubotyというチャットボットフレームワークで実装されています。
rubotyの特徴は、やはり全てをrubyで書けるという点に尽きると思います。
プラグインによる拡張が容易になっており、現在でも様々なプラグインが公開されています。
弊社で使っているrubotyはgithub上に[feedforce-ruboty](https://github.com/feedforce/feedforce-ruboty)として公開されているので、どんなプラグインを使っているのか興味をお持ちの方は是非見てみてくださいね！

### Heroku

[Heroku](https://www.heroku.com/home)は、Webアプリの開発から公開まで可能なプラットフォームを提供するクラウドサービスです。
インフラには[AWS](http://aws.amazon.com/jp/)、バージョン管理には[Git](http://git-scm.com)が使用されています。
なんといっても寛大な無料枠があるのが特徴で、[1日18時間の利用制限](https://blog.heroku.com/archives/2015/5/7/heroku-free-dynos)などの制限はあるものの、無料で利用することができます。
課金によってスペックを柔軟に変更することもできるので、スケーラビリティの点からも優れています。
feedくんはHerokuにデプロイされて動作しています。

### redis(Redis To Go)

[redis](http://redis.io)は、キーバリューモデルを採用するNoSQLとして有名です。
メモリ上にデータを展開するので、読み書きが高速であるという特徴があります。
[Redis To Go](http://redistogo.com)は、redisサーバーをクラウドから利用することができるサービスです。
Heroku上で[アドオン](https://addons.heroku.com/redistogo#nano)が提供されており、アプリに対して簡単にredisを組み込むことができます。
redisは、feedくんに登録したジョブを永続的に保持するために利用しています。

## 「ジョブをまとめて編集する」ことが必要になった背景

今回の本題の背景をご説明しましょう。

以前ruboty-cronのアップデートが入った際に、登録してあるジョブのフォーマットを全て変更する必要がありました。
変更に当たってSlack上からfeedくんに登録されているジョブの一覧を参照したのですが、どのチャンネルで登録されたジョブか分からず、ジョブの再登録に当たっては結局登録した人の記憶頼りとなってしまいました。

今回はそのような場合に、登録したジョブを取得してまとめて編集する方法をご紹介します。

## feedくんの脳みそを解剖する（ジョブの取得）

では早速、feedくんの脳みそ（Redis To Go）から登録されているジョブを取り出してみましょう。
弊社では開発言語としてrubyが使われることが多いので、今回紹介するスクリプトでもrubyを使用しています。

### アクセス情報をHerokuから取得する

まずrubotyをデプロイしているHerokuにアクセスして、Redis To Goのアクセス情報を取得します。

アクセス情報はHeroku上の環境変数に保存されているので、ターミナルからHerokuにアクセスして環境変数を参照します。
その際には、[Heroku Toolbelt](https://toolbelt.heroku.com)のインストールが必要なのでご注意ください。

それでは実際にHerokuにログインして、Herokuのコンソールを立ち上げてみましょう。

```
$ heroku login
$ heroku run console --app アプリ名
```

コマンドを実行すると、次のような表示になります。
デフォルトではHeroku上でirbが立ち上がるようになっています。

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

この値がRedis To Goにアクセスするために必要な情報となります。

### Redis To Goにアクセスする

それではHerokuのコンソール上でrubyを使ってredisにアクセスしてみましょう！

今回はredisに簡単にアクセスするために、[redis-rb](https://github.com/redis/redis-rb)というgemを使います。

```ruby
require 'redis'
redis = Redis.new(url: ENV['REDISTOGO_URL'])
```

上のスクリプトを実行するとredisというインスタンスが生成されます。
このインスタンスを通して、redisに対して様々な操作を行うことができます。

### データを取得する

それではredisインスタンスからgetメソッドを呼び出して、登録されているジョブを取得しましょう。

rubotyはデフォルトで`ruboty:brain`というキーにデータを保存するよう設定されています。

```ruby
raw_data = redis.get("ruboty:brain")
```

raw\_data変数に取得したデータが格納されており、中身を見てみると、エンコードされた判読不能な文字列しか得られません。
このままでは非常に残念な感じになってしまうので、そのデータを判読可能な状態に変換してあげる必要があります。

### 取得したデータをオブジェクトに変換する

rubotyはジョブを登録するとき、ジョブのオブジェクト情報を、[Marshalモジュール](http://rurema.clear-code.com/2.2.0/class/Marshal.html)のdumpメソッドでテキスト情報に変換してredisに保存しています。
なので、今回redisから取得したデータは`Marshal.load`で元のオブジェクトに戻してあげます。

```ruby
Marshal.load(raw_data)
```

上記スクリプトを実行すると、登録したジョブがハッシュとして取得できます。

## feedくんの記憶を改竄する（ジョブの編集）

feedくんの脳みそから無事ジョブデータを取得することができました。

それでは次に、取得したジョブデータを編集してfeedくんの脳みそに戻す方法をご紹介しましょう。

### ジョブデータの構造

ジョブのハッシュは、次のようなデータ構造になっています。

```ruby
{0001=>
  {"body"=>"feedkun: echo Hello FeedForce !!",
   "from"=>"チャンネル名@hogehoge.xmpp.slack.com/登録したユーザ名",
   "from_name"=>"登録したユーザ名",
   "to"=>"feedkun@hogehoge.xmpp.slack.com/slack-nnnn",
   "type"=>"groupchat",
   "id"=>0000,
   "schedule"=>"* * * * *"},
 0002=>
  {
   ...
  }
  ...
}
```

ハッシュの各キーには、次のような値が格納されています。

- *0001*
任意の4桁の数字（ジョブID）

- *body*
ジョブとして登録するメッセージの本文

- *from*
どのユーザーがどのチャンネルで登録したジョブなのか

- *from_name*
ジョブを登録したユーザーの名前

- *to*
どのボットに対してジョブを登録したか

- *type*
ジョブの登録先がチャンネルの場合は`groupchat`、ダイレクトメッセージの場合は`chat`

- *id*
ジョブID（上記例だと0001や0002のこと）

- *schedule*
[crontab形式](https://ja.wikipedia.org/wiki/Crontab)による発言スケジュールの設定

各項目の細かいデータフォーマットに関してはRubotyの作者である[r7kamuraさんのブログ記事](http://r7kamura.hatenablog.com/entry/2014/05/14/041123)にて一部紹介されているので、興味を持った方はそちらを見てみてください。

### ジョブを編集する

それでは実際に登録されたジョブを編集してみましょう！

ジョブのハッシュは以下の通りになっているものとします。

```ruby
{0001=>
  {"body"=>"feedkun: echo Hello FeedForce !!",
   "from"=>"feedforce-channel@hogehoge.xmpp.slack.com/otofu_square",
   "from_name"=>"otodu_square",
   "to"=>"feedkun@hogehoge.xmpp.slack.com/slack-nnnn",
   "type"=>"groupchat",
   "id"=>0000,
   "schedule"=>"* * * * *"},
  ...
}
```

#### 本文を変更する

本文を変更するには、ハッシュの*body*の要素を編集します。

今回は`feedkun: echo Hello FeedForce !!`という内容を、`feedkun: echo Hello otofu_square !!`に変更してみます。
ちなみにFeedくんに`feedkun: echo hogehoge`と話しかけると、*echo以下*の内容を発言してくれます。
本文を変更するには、ハッシュの*body*の要素を変更します。

現時点でジョブのハッシュの*body*には編集前の本文が入っているので、下記のように*echo以下*を`Hello otofu_square !!`に変更します。

```ruby
{0001=>
  {"body"=>"feedkun: echo Hello otofu_square !!",
   ...
  }
  ...
}
```

こうすることで、このジョブの発言内容を新しいものに置き換えることができます。

#### 発言スケジュールを変更する

発言スケジュールはジョブのハッシュの*schedule*に格納されています。
スケジュールは[crontab形式](https://ja.wikipedia.org/wiki/Crontab)で記述されますが、現状のままだと毎分発言が繰り返されてしまいます。

今回はfeedくんに朝の挨拶をしてもらうように、毎週月〜金の午前8時00分にスケジュールを変更してみましょう。
上記スケジュールをcrontab形式で表現すると、`0 8 * * 1-5`となるので、

```ruby
{0001=>
  {...
   "schedule"=>"0 8 * * 1-5"}
  ...
}
```

上記のように変更します。

#### 発言チャンネルを変更する

現在の状態だと、このジョブの発言チャンネルは*feedforce-channel*に設定されています。
今回は、*greeting-channel*で発言してもらうように変更してみましょう。

```ruby
{0001=>
  {...
   "from"=>"greeting-channel@hogehoge.xmpp.slack.com/otofu_square",
   ...}
  ...
}
```

上記のようにすることで、発言チャンネルを*greeting-channel*に変更することができます。

### 編集した内容をRedis To Goに再登録する

編集したジョブの情報をredisに再登録するには、ジョブのハッシュオブジェクトを`Marshal.dump`で文字列に変換してから、redisの`ruboty:brain`キーにセットする必要があります。
ハッシュオブジェクトを文字列に変換するには、下記のスクリプトを実行します。

```ruby
hash = {
 0001=>
  {"body"=>"feedkun: echo Hello otofu_square !!"
   "from"=>"greeting-channel@hogehoge.xmpp.slack.com/otofu_square",
   "from_name"=>"otodu_square",
   "to"=>"feedkun@hogehoge.xmpp.slack.com/slack-nnnn",
   "type"=>"groupchat",
   "id"=>0000,
   "schedule"=>"0 8 * * 1-5"},
 0002=>
  {...
   ...}
 0003=>...
 ...
}

result = Marshal.dump(hash)
```

実行すると、*result*にハッシュオブジェクトを文字列化したデータが代入されます。
あとはこの*result*のデータをredisの`ruboty:brain`キーにセットしてあげましょう。

```ruby
redis.set("ruboty:brain", result)
```

これでジョブの再登録が完了しました。

## まとめ

この記事では、rubotyに登録されたジョブを、redisから取得したデータを変更することで編集する方法をご紹介しました。

何らかの理由でジョブをまとめて再登録したい場合や、複数のジョブの発言チャンネルを変更したい場合には有用な方法になると思います。

そもそもrubotyを知らなかった！という方や、知っていたけどredisやruboty-cronを使ったことはなかった！という方は、是非この機会に試してみて、ここでご紹介した内容も実践してみていただけると嬉しい限りです。
