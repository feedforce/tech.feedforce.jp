---
title: 今年ソーシャルPLUSで捨てられた技術たち
date: 2015-12-12 00:00 JST
authors: masutaka
tags: operation, ruby, aws
---
この記事は[フィードフォースエンジニア Advent Calendar](http://www.adventar.org/calendars/906) 12日目の記事です。
11 日目は [meihong](http://www.adventar.org/users/9675) の海外ヴァカンスの話（TODO: あとでアップデートする）でした。

こんにちは。先週美容院デビュー<del>に失敗</del>した増田です。
日々イケメソに近づいております。怖いです。

<!--more-->

Advent Calendar のネタはなにかないかなあと考えていたら、私は[ソーシャルPLUS](https://socialplus.jp/)の開発リーダーでした。そういえば。

それで思いついたのが『今年ソーシャルPLUSで捨てられた技術たち』。

開発リーダーとして 1 年を振り返るという口実は説得力がありますし、最小の労力で最大の効果を発揮するにはこのようなまとめ記事は最適です。(๑´ڡ`๑)

それではダラダラ始めます。

## Rails3

今年の上半期にようやく Rails4 にアップデートすることができました。
ほぼ全て [tmd45](http://www.adventar.org/users/2076) と surume にお任せで、私は記憶がありません。

世の中の記事を見渡してみると、それなりに大変だったものの問題なく Rails4 にアップデートできている様子。しかし、うちはドハマリして一回諦め、二回目でリベンジ出来ました。

ソーシャルPLUSが API やウィジェット機能を提供するサービスであるため、動作確認が難しいことは原因の一つだと思います（もちろんテストは書いてますよ！）。

中でも分かりづらかった Rails4 の変更は [String#to_json が Unicode escape しなくなった](https://github.com/rails/rails/commit/815a9431ab61376a7e8e1bdff21f87bc557992f8)こと。気づくのに時間がかかりました。JSON の仕様としては正しいため問題があるわけではありませんが、API サーバとしての振る舞いが変わるため、我々としては知る必要がありました。

あと、なぜかテストで使っていた [activerecord-tableless](https://rubygems.org/gems/activerecord-tableless) もこのタイミングで捨てました。

## KyotoTycoon

[KyotoTycoon](http://fallabs.com/kyototycoon/) は memcached 互換のキーバリューストアです。でも、Rails4 で必要なバイナリプロトコルを完全にサポートしていません。

Rails4 へのアップデートの前に代替サービスに乗り換える必要がありました。

[Amazon ElastiCache](https://aws.amazon.com/jp/elasticache/) の採用は早々に決めていましたが、エンジンを Memcached と Redis のどちらにするか悩みました。

最終的に以下の理由から Redis に決めました。

* Memcached だとメンテナンスウィンドウの時にセッションが消えるのが嫌
* 今までどおりデータがストレージに保存される安心感
* 今までどおりレプリケート機能が使える
* 他、Redis のほうが面倒くさくない印象を受けた

導入から 1 度もトラブルがなく、非常に満足しています。どの項目を監視対象にすればよいか分からず、非常に焦ったこともありましたが、それはまた次回にでも。

Zabbix による監視で使用していた温かみのある手作りスクリプトを fluentd plugin に移行できたことも収穫でした。この記事で紹介しています。

[ElastiCacheをCloudWatch+fluentd+Zabbixで監視する | feedforce Engineers' blog](/elasticache.html)

KyotoTycoon の rpm は配布されておらず、自前で作っていました。それを捨てられたのも良かったです（そういえば 2 つあったのだった）。

* https://github.com/feedforce/kyototycoon-rpm
* https://github.com/feedforce/kyotocabinet-rpm

## RSpec2

こちらも無事 RSpec3 にアップデートすることができました。tmd45++

## 秘伝の nginx.spec

ソーシャルPLUSでは Nginx の [headers-more-module](http://wiki.nginx.org/NginxHttpHeadersMoreModule) が必要なため、自前で rpm をビルドしています。

* https://github.com/feedforce/nginx-headers-more-rpm

長いこと秘伝の nginx.spec を使ってきましたが、公式の SRPM にパッチを当てるだけで済むように再構築しました。今まで作れなかった CentOS7 用の rpm も簡単にビルド出来るようになりました。

GitHub にリリースすることで、Chef のレシピからインストール可能にしています。

* https://github.com/feedforce/nginx-headers-more-rpm/releases

## keepalived

あるサーバの冗長化のために keepalived を使っていたところを、[Amazon Route53](https://aws.amazon.com/jp/route53/) の Health Check できれいに置き換えることが出来ました。

こちらの記事がピッタリハマりました。クラスメソッドさん++

[Amazon Route 53のDNSフェイルオーバー機能を利用したリージョンを跨いだバックアップサイトの構築（EC2 to EC2編） ｜ Developers.IO](http://dev.classmethod.jp/cloud/route-53-dns-failover-ec2/)

## Facebook Graph API v1.0

2014/4/30 の [F8](https://www.fbf8.com/) で Graph API v2.0 が発表され、v1.0 は今年の 4/30 に消滅しました。

我らがソーシャルPLUSは当然 Facebook ログインをサポートしているため、v1.0 に関わる処理や機能を削除することが出来ました。

## Jenkins

意外なことに [Jenkins](https://jenkins-ci.org/) も今年でした。

今年の 1 月に急にうちの Jenkins が動かなくなりましたが、直すのも面倒になったため [CircleCI](https://circleci.com/) に乗り換えました。

やったことは circle.yml を追加して timezone を指定したくらいです。その後、[高速化のための並列実行](https://gist.github.com/sakatam/7374387)を仕込んだりもしましたが、Jenkins の日々のアップデートに比べたらノーメンテナンスみたいなものです。[最近は metadata を食わせられるようになり](https://circleci.com/docs/test-metadata#automatic-test-metadata-collection)、Jenkins にもう一歩近づきましたね。

過去にこんな記事も書きました。Jenkins さん、今までありがとうございました！

[JenkinsでサーバのCIを始めました | feedforce Engineers' blog](/jenkins-server-ci.html)

## Chef による crontab の管理（アプリケーション側のみ）

アプリケーション側の cron job の管理を Chef から [whenever](https://rubygems.org/gems/whenever) に移行しました。

Chef はサーバの構成管理ツールなので、アプリケーション側の cron job を管理するのはバッドプラクティスでしたね。

そもそも crontab を使うのはイケていませんが、今は仕方がない。ソーシャルPLUSには whenever はうまくハマりました。

## 感想

Qiita:Team の記事を探してみたら、意外にたくさんありました。

現段階で作業中のタスクはこんなのがあります。

* Redmine にある API マニュアル
     * GitHub に移植中
* アラートメール
     * [Bugsnag](https://bugsnag.com/) に移行中

来年もどんどん捨てて新陳代謝を良くしていきます！


明日 13 日目は今回 2 回目の登場、優しい髭の人 [kasei_san](http://www.adventar.org/users/7355) です。
