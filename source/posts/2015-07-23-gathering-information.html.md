---
title: 『最近の情報収集方法』というお題で発表しました
date: 2015-07-23 13:00 JST
authors: masutaka
tags: resume
---
増田です。GitHub のフィードを日夜監視する毎日です。

社内勉強会で『最近の情報収集方法』という発表をしたので、このブログでもお知らせします。

発表後に参加者の皆さんからも情報収集方法を教えてもらったり感想を頂いたので、私のコメントともに記載しました（大変な量になってしまった...）。

<!--more-->

## 発表の内容

使ったスライドはこちらです。

<script async class="speakerdeck-embed" data-id="34a40b051dd14697be779dbba3ce1068" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>

※ 資料にあるリンク等をコピペしたい場合は [Speaker Deck のページ](https://speakerdeck.com/masutaka/zui-jin-falseqing-bao-shou-ji-fang-fa)から PDF をダウンロードし、お手元のアプリで開けば可能です。

### 概要

* なるべく情報を取りに行かずに済むようにしている
* 情報の量や密度をコントロール可能にしている
* コードを書けたので問題解決の幅が広がった
* フィードフォースの社員なのでフィードと仲良く

### 技術系

* [HBFav](http://hbfav.bloghackers.net/)
    * iPhone を置いておくだけで情報が降ってくる
* [Twitter](https://twitter.com/)
    * 興味あるアカウントのリストを作成
    * [@masutakafeed](https://twitter.com/masutakafeed) を作成し、フィードを [IFTTT](https://ifttt.com/) 経由でポスト
        * はてブのタグフィード
            * はてブのタグからは柔軟にフィードを取得できる
            * 例: Rails、はてブ数 3 の新着を RSS で
                * http://b.hatena.ne.jp/search/tag?q=rails&users=3&sort=recent&mode=rss
                * `&mode=rss` を外せば HTML になる
        * GitHub のプライベートフィード
            * 会社のフィードを除外するために [Awesome GitHub Feed](https://github.com/masutaka/awesome-github-feed) を作成
* [feedly](https://feedly.com/)
* ポッドキャスト
    * http://rebuild.fm/
* 自分のブログ
    * http://masutaka.net/chalow/

### 一般ニュース

* [LINE NEWS](https://news.line.me/)（iOS）
* [SmartNews](https://www.smartnews.com/ja/)（iOS）
* [はてなブックマーク](https://itunes.apple.com/jp/app/id354976659)（iOS）

### その他

* [Pocket](https://getpocket.com/) を少々
    * あとで読む系のサービスはあとで読まない
* [Google アラート](https://www.google.co.jp/alerts)
    * ゲームの最新情報を追うのに良い

## 参加者の情報収集方法

発表後、付箋に書いて頂きました。参加者は全員エンジニアでした。

* Twitter（9名）
    * [#gcpja](https://twitter.com/search?q=%23gcpja&src=typd&vertical=default&f=tweets) や [#gcpug](https://twitter.com/search?q=%23gcpug&src=typd&vertical=default&f=tweets)
    * tech-news リストとか、いくつかのリストを作って、[Tweetbot](http://tapbots.com/tweetbot/) でカラム別に表示して読んでる
    * LIST（dev, ff, FFメル）
    * Search（ruby, rails, middleman,...）
    * すごい人の Twitter を見てると、なんとなく取捨選択後の情報が
    * 興味のある人をプライベートリストで
* はてブ（6名）
    * [ホットエントリ](http://b.hatena.ne.jp/hotentry)
    * 会社の人のはてブ
    * [Presso](https://itunes.apple.com/jp/app/id799334646) で興味あるタグをフォロー
    * HBFav（3名）
        * HBFav のために iPhone を買った（といっても過言ではない）
        * めっちゃフォローして Twitter みたいな使い方してます！！
* feedly（5名）
    * 情弱なので RSS を少々
    * セキュリティ関連のブログとかだけ...
    * 未読意識してないですー
* Qiita（3名）
    * 特定のタグを RSS で取得できるのを知った
    * Ruby, Vim, Rails の RSS
    * めぼしいフィードは読む
* [Gunosy](https://gunosy.com/)（3名）
    * 朝夕のメールで
    * Web で
* [JSer.info](http://jser.info/)
* [Frontend Weekly](https://frontendweekly.tokyo/)（メルマガ）
* [スタック・オーバーフロー](http://ja.stackoverflow.com/)
    * Ruby 等の RSS
* はてなブログを購読
* Facebook
* CentOS のメーリングリスト
* [Alfred](http://www.alfredapp.com/)
    * Qiita の Stock, Pocket, [Evernote](https://evernote.com/), GitHub の情報取り出しに利用
* [Live Dwango Reader](http://reader.livedoor.com/)
* Pocket
    * feedly から [Press](https://play.google.com/store/apps/details?id=com.twentyfivesquares.press&hl=ja)（Android） 経由で POST
    * Twitter の非公開リストから [Fenix](https://play.google.com/store/apps/details?id=it.mvilla.android.fenix&hl=ja) （Android）経由で POST
    * 帰りの電車で気にやったやつだけ読む
    * スターを付けると IFTTT 経由で Evernote に送信
* [Ruby Weekly](http://rubyweekly.com/)（メルマガ）
* SmartNews
* [Hacker News](https://news.ycombinator.com/)
* GitHub のフィード
    * 絶対読む
* [im.kayac.com](http://im.kayac.com/)
    * メールを通知

## 参加者からの感想

感想も頂きました。リストの 2 階層目は私からのコメントです。

* awesome-github-feed コード見てみたい。見る
    * 恥ずかしいです
* Twitter 情報の密度少ない
    * 人生は短いですからね
* メンテナンスが面倒になって諦めちゃうのはどうすれば
    * （Twitter のリストなどのメンテナンスが面倒とのこと）
    * 自分に合う方法を取れば良いかと
* アウトプットをインプット、名言頂きました
    * ありがとうございます
* GitHub のプライベートフィードのモザイク気になる
    * ほとんどフィードフォースです。資料の公開を考えていたので
* Twitter フォロー減らす
    * もう少し厳選すれば良かったです
* GitHub フォローしている人のアクティビティって欲しい？
    * アクティビティというより、フィードが欲しいのです。手段の目的化...
* 「アクティブデスクトップ」とかヤバい！
    * OFF にしてましたけどね。ブラウザも IE4 ではなく Netscape Navigator 4.0x を愛用していました
* Gunosy の前は Crowsnest 使ってた！
    * お
* 今の情報収集方法、課題感ある？
    * 技術書をもっと読まないと...
* [29hours](https://github.com/june29/29hours) 試してみようー
    * 是非〜
* Twitter、公式はアドツイートが微妙ですよねー
    * アドはまだ技術が追いついてませんね
* おもしろかった！
    * ありがとうございます！
* アクティビティみられるのやだなw
    * 申し訳ありません
* 公開リポジトリでも全然緊張感持っていない...
    * 機密情報だけですね。私もソースコードには緊張感持ってないです
* Nokogiri じゃない [Oga](https://rubygems.org/gems/oga) っていうのあります
    * 「のこぎり」に対する「おが」ですかw
    * libxml 必要ないのですね。使ってみようかな
* 組み込み 11 年のキャリア
    * どこかに忘れてきました...
* 技術者ブログに up して欲しいな（色んなキャリアの人がいるよ）
    * I am writing...
* 聴いている人も自分のやり方とか教えてね、というノリいいですね
    * ありがとうございます。気負いも減るので良いかも
* 他の人の情報収集方法を聴けてよかった
    * まとまって聴く機会、少ないですよね
* 「投資の価値ある」は価値がある情報
    * 値段よりも「投資の価値あるか」に重きをおいております
* Google アラートためしてみようかな
    * おお、是非に！
