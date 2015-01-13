---
title: 執事のセバスチャンが東京ドームのイベントをHipChatで教えてくれる
date: 2014-06-11 11:45 JST
authors: e-takano
tags: ruby
---
こんにちは、 kano-e です。 HipChatで好きな emoticon は ![(ghost)](/images/2014/06/429bf35a-97ae-e2ee-f374-f9364cbc885f.png "(ghost)") です。

今日は **HipChat API** と HipChat API を使った **執事のセバスチャン** についてお話したいと思います。

<!--more-->

## まずはセバスチャンの紹介

執事のセバスチャンは東京ドームのイベントを教えてくれる Ruby 製の HipChat Bot です。

弊社フィードフォースは後楽園駅徒歩五分、窓を開ければ東京ドームシティのジェットコースターの歓声と絶叫。 便利で素敵なロケーションなのですが、東京ドームでコンサートや野球の試合がある日には混雑に巻き込まれる悲劇も多々。

![お店どこも混んでる](/images/2014/06/crowd.jpg)
「あれ、今日何かイベントやってるんだっけ？ うわ、お店どこも混んでる……」※ 写真はイメージです

そんな悲劇を防ぐのが、セバスチャンの仕事のひとつです。

[東京ドーム](http://www.tokyo-dome.co.jp/dome/schedule/)や[東京ドームシティホール](http://www.meetsport.jp/hall)でイベントのある日には、

 ![東京ドームでは 18:00 より 【巨人戦】巨人　ー　横浜DeNA 開催でございます。お帰りのお時間にはお気をつけ下さい。](/images/2014/06/790332da-ed51-9dcf-765b-e53e76e4cc15.png)

このようにセバスチャンがお知らせをしてくれます。

ほかには、 MTG の時間になったら教えてくれたり、

 ![まもなくのご予定がございます。18:00より 新人さんふりかえり 以上でございます。](/images/2014/06/bc58e64b-6a0e-8001-46e2-4f402f20fec2.png)

業務終了の時間を教えてくれたり、

 ![まもなく業務終了のお時間でございますが、お仕事のおかげんはいかがでしょうか。戸締まり用の鍵はご準備よろしゅうございますか？](/images/2014/06/ed4d7922-4b19-054a-19d2-c09a40fa7298.png)

朝には1日のスケジュールを読み上げてくれたりなど、

 ![おはようございます。5月9日金曜日でございます。本日のご予定をお知らせいたします。 10:30 より CF朝会](/images/2014/06/8dc2c5ad-2a9c-857e-312d-0a6010f2c59b.png)

HipChat 上でいくつかの仕事をこなしています。

## ここからは HipChat API の話を

[HipChat](https://www.hipchat.com/) では API が公開されていて、その API を使うためのライブラリも各種言語で用意されています。

Ruby の場合[hipchat-rb](https://github.com/hipchat/hipchat-rb) を使えば、

```
client = HipChat::Client.new(access_token, api_version: 'v1')
room = client[room_id_or_name]
room.send(
  'Sebastian',
  'おはようございます。5月9日金曜日でございます。',
  color: 'yellow',
  notify: true,
  message_format: 'text'
)
```

これだけのコードで、

 ![おはようございます。5月9日金曜日でございます。](/images/2014/06/2888d8ec-1dd8-c0c0-17ce-c2f934f28908.png)

こんなふうに、投稿できてしまいます。

ご覧の通りとても簡単なのですが、実際に bot 運用しようとしたときには、 API のバージョンや指定するオプションのことなどで、少し迷ったり調べたりすることもありました。 先程のコードに解説を入れる形で、その辺りのことをざっくりとまとめたいと思います。

### HipChat::Client.new ... アクセストークンと API バージョンについて

```
client = HipChat::Client.new(access_token, api_version: 'v1')
```

 **HipChat::Client** のインスタンスを作る時には、アクセストークンの指定が必要です。 オプションの **api\_version** は **v1** か **v2** を指定します。 省略された場合のデフォルトは **v1** です。

 **api\_version** にどちらのバージョンを指定するか、なのですが。 バージョンによって使える API も変わり、また、必要なアクセストークンの取得方法も違ってきます。 なので、まず使い道にあった **api\_version** はどちらなのか、考える必要があります。

#### api\_version v1

[v1のAPI](https://www.hipchat.com/docs/api) を使う場合は Group Admin にある API メニューから発行するトークンが必要です。 v1 の API は、主に room の操作(投稿を含む)か user の操作を行うものになります。

トークン発行時に type を Admin にすると room の新規作成など v1 の API がすべて使用可能です。 type を Notification にした場合、使える API は[rooms/message](https://www.hipchat.com/docs/api/method/rooms/message) と[rooms/topic](https://www.hipchat.com/docs/api/method/rooms/topic) のみです。

この辺りは[Authenticationのページ](https://www.hipchat.com/docs/api/auth) に説明がまとまっています。 room に投稿したい程度の用途であれば Notification で OK です。

#### api version v2

[v2のAPI](https://www.hipchat.com/docs/apiv2) の場合、用途によって取得するトークンが変わります。

まず、ユーザ毎の設定メニュー(Account settings > API access)から、ユーザのトークンを取得できます。 ユーザのトークンなので、例えば room へ投稿した場合も v1 の API と違って投稿者名の指定はできず、ユーザ自身の投稿となります。

また、 room の管理者であれば room のトークンを発行できます。 このトークンでは、その room に対してのみ操作が可能です。 room への投稿は "Notification" という投稿者名になります。

ほかに Add-on を使う時に発行されるトークンもあるのですが、この記事では説明を省略いたします。

#### さて、どっち？

では、改めて v1 と v2 どちらかを選んでトークンを発行します。

セバスチャンは、そもそも[roomに投稿するAPI](https://www.hipchat.com/docs/api/method/rooms/message) しか使いません。 あとは **どうしても Sebastian という名前で投稿したい** ので v1 を使うことにしました。

### HipChat::Client#[] ... 部屋を指定

以下のコードで room を指定しています。

```
room = client[room_id_or_name]
```

HipChat の API で部屋を指定した場合、 room\_name と room\_id のどちらでも受け付けてくれるようになっているようです。

web から room の情報を見ると確認できる API ID という項目が room\_id です。 それを使って、 API で部屋を指定することができます。

room\_name の指定でも構わないのですが、 room\_name はユーザが自由に変更できてしまいますし、 room\_name の変更があると当然古い room\_name での指定は使えません。

ルーム名変更に怯えなくて済む room\_id を使う方が安心です。

### HipChat::Room#send ... 実際に部屋に投稿する

さて、実際に投稿を行っているのは以下の部分です。

```
room.send(
  'Sebastian',
  'おはようございます。5月9日金曜日でございます。',
  color: 'yellow',
  notify: true,
  message_format: 'text'
)
```

第一引数は投稿者名、 これは hipchat-rb の仕様では必須なのですが、 v2 の API を使っている場合は、何を指定しても無視されます。

第二引数は、ご覧の通りの投稿内容。

それ以降はオプションです。 オプションは必須ではないため、実は投稿したいだけであれば、

```
room.send('Sebastian', 'おはようございます。5月9日金曜日でございます。')
```

これだけでもできてしまいます。

それでは、

```
color: 'yellow',
  notify: true,
  message_format: 'text'
```

この部分は何を指定しているのか、ここからはその話になります。

#### :color ... テスト通ったお知らせは緑色にしたいな

APIからの投稿の時には **color** パラメータで投稿の背景色を選ぶことができます。 選べる色は **yellow** , **red** , **green** , **purple** , **gray** の5色。

デフォルトは **yellow** です。 (ですので、実はセバスチャンの **color: 'yellow'** という指定は、なくても問題ないものだったりします)

ほかにも **random** という指定が使えるのですが、これの使い所がいまいちわかりません。

#### :notify ... API での発言て通知されないの？

参加している room 内で新しい投稿があると、アプリでは room 名の色が変わって新着の投稿が通知されるようになっています。 API 経由での投稿は、通常はそういった通知はされません。

ですが、あえて通知させたい、という時はあるかと思います。 例えば、エラーがあったら気付けるように通知されて欲しい、というような場合です。

その場合は、 **notify** というパラメータで制御可能です。

v1 の API では boolean なパラメータは、値として **1** or **0** 、v2 では **true** or **false** を指定することとなっています。 hipchat-rb では バージョンの違いを考えずに boolean を指定できるようになっており、 **true** or **false** を渡せば、バージョンに応じたパラメータに変換してくれます。

#### :message\_format ... emoticon 使いたい

API から emoticon を使いたい場合は **message\_format** パラメータで **text** を指定する必要があります。

何も指定しないと、デフォルトで **html** フォーマットになります。  

**html** フォーマットでは、簡単なタグが有効になる代わりに emoticon の表示は無効になります。  

**text** フォーマットでは逆に、 emoticon の表示が有効になって、タグは使えません。

長い URL を共有したい、といった場合は **html** フォーマットにするなど、用途によって使い分けができます。 セバスチャンが **text** フォーマットを使っているのは emoticon を使いたかったからです。

![(ff) 16:00より 制作MTG](/images/2014/06/2b2937eb-3312-748b-6424-6bef6c0292b3.png)

HipChat はオリジナルの emoticon が登録できるので、自社ロゴなどを登録して使っています。

## 本日もお疲れさまでございました

さて、 **HipChat API** と **執事のセバスチャン** の話、だいぶざっくりでしたが、本日はここまでにしたいと思います。

家の子自慢のような「こんな bot 作ったよ」とかの話が好きなので、もっと bot 紹介記事増えろー、と念じながら書きました。 みなさんの bot 紹介を待っています！

![皆様、本日の業務時間は終了でございます。本日もお疲れ様でございました。](/images/2014/06/82b5335c-6a8d-cf5f-ad7a-338340d5f78f.png)

