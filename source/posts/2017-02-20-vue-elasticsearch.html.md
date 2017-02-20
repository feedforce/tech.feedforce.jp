---
title: 自分のブログに Elasticsearch + Vue.js で検索機能を付けたという発表をした
date: 2017-02-20 15:00 JST
authors: masutaka
tags: resume
---
こんにちは。寒がりすぎな増田です。いつからだろう？

先週金曜日に社内勉強会で掲題の発表をしました。感想や質問も頂いたので、返信という形で記事として記録しておきます。

<!--more-->

## スライド

<script async class="speakerdeck-embed" data-id="514f1a6d5b9b49f6b50368fd5cc18e41" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>

## 発表の内容

* https://masutaka.net/chalow/ に自前で検索機能を付けた
    * https://masutaka.net/chalow/search.html
    * フロントエンドは [Vue.js](https://jp.vuejs.org/) で実装。バックエンドは [nginx](https://nginx.org) のリバースプロキシを介した [Elasticsearch](https://www.elastic.co/jp/products/elasticsearch)
    * 今のところ、記事データの Index は Elasticsearch の Bulk API でデプロイのたびに作り直している
* ついでに [Google Custom Search Engine](https://cse.google.co.jp/) でも実装した
    * https://masutaka.net/chalow/search-google.html
* 『[ChangeLog メモ](http://0xcc.net/unimag/1/)』と、その静的 HTML ジェネレータ [chalow](http://chalow.org/) も紹介

## 感想や質問

※ リストの 2 階層目は私からのコメントです。

### 今回の検索機能

* ちゃんとかたまり１つ作り上げるのすごい... 自分の、やり切り力足りなさ
    * 今回はむしろスライド作成に心が折れそうになりました...
* 検索データは html から作ってたけど、元の txt ファイルからじゃダメなの？
    * chalow を改造すれば、絶対そのほうが良いです。今回は疲れていたので、Ruby に逃げました（chalow は Perl 製）
* 私は全文検索に [Algolia](https://www.algolia.com/) つかってます :)
    * search.masutaka.net 使っていいよー
* 隠しコマンド良い
* 隠しリンク！
    * 90 年代に初めてホームページ(!)を作った頃を思い出して付けました
* ユーザーに検索機能どのくらい使われてますか？
    * 多分私だけです(ｷﾘｯ
    * nginx のログを Kibana で可視化すれば把握は可能です
* [Oga](https://rubygems.org/gems/oga) 知らなかった
    * Nokogiri と違って、libxml 使わないのが最高です
    * [IO を渡せば、Nokogiri より速いみたいです](http://qiita.com/gravitonMain/items/720f441713b1378fe55c)
    * もう Nokogiri を使う理由はないと思いますね
* インポートの負荷は高くないのかな？ デプロイの時間も気になる
    * HTML をパースして JSON を作るのに 60 〜 70秒、インポートは 10 秒未満ですね。パースが長い
    * デプロイ時間は 4 〜 5 分で、そのうち HTML の生成は 15 秒ほどですね

### フロントエンド

* フロントの人達怖い...
    * やさしい方々ばかりですよ
* マスカット Vue2 の勉強会早よ
    * （言えてない...）すみません！ すぐに！
* あくしおす
* あくしぃぁうす
    * よい発音です
* 発音がちょっと...
    * ｱｸｼｨｧｳｽ
* Riot.js もよろしくお願いします（◯ねって言われそう）
    * ◯は伏せ字にしましたw
    * 評判が良くなかったので、なんとなく避けました
    * [Vue.js のガイドに Riot.js と比較がある](https://jp.vuejs.org/v2/guide/comparison.html#Riot)ので、参考にしてみて下さい。他のフレームワークとの比較もあります
* Vue.js の人りりしい
    * [たしかに...](https://github.com/yyx990803)
    * （Issue や PR のリンクが Twitter に流れると、りりしいお顔が拝見できるそうです）
* Vue.js よさそう!!
    * とにかくハードルが低くて良いです。そこから JS の世界を広げていけばよいかと(ｵﾏｴﾓﾅｰ

### Elasticsearch + Kibana

* 電子書籍全文検索システムで使おうと思ったことがある
    * その後どうしたのか気になります
* Mongo クエリよりつらそう
    * 雰囲気が[ポーランド記法](https://ja.wikipedia.org/wiki/%E3%83%9D%E3%83%BC%E3%83%A9%E3%83%B3%E3%83%89%E8%A8%98%E6%B3%95)っぽいので、慣れれば Lisper は書きやすいかも？
* Kuromoji 試したい
    * [textlint](https://github.com/textlint/textlint) でも使われているみたいですね
    * [この技術者ブログは CI の時に textlint を使ってます](https://github.com/feedforce/tech.feedforce.jp/blob/86d7b8728b5d23e77985a41d5322c6a1b3b793b9/circle.yml#L13)
* Kuromoji の他の Analyzer どんなのが？（Qiita とか何使ってるのかな）
    * [GitHub は Elasticsearch 使っているみたいですね](https://speakerdeck.com/johtani/elastic-stackwoli-yong-site-detakarayang-naqi-dukiwojian-tukeru?slide=44)
    * [Qiita と Qiita:Team でも使っているみたいです](http://blog.qiita.com/post/101162528979/new-qiita-search)
* 学習コスト高いですよね
    * そうなんですよ。ライトな検索にはコストが高いと思いました
* Kibana 5 いいなぁ〜 使いやすそう
    * [Elastic Cloud](https://www.elastic.co/jp/cloud) がいろいろお手軽です
* ![ド・モルガンの法則](/images/2017/02/de-morgan.jpg)
    * [Elasticsearch の Bool Query](https://www.elastic.co/guide/en/elasticsearch/reference/5.1/query-dsl-bool-query.html) に should_not がない理由で話に出しましたね

### 見学者の方から

今回は社外から見学者の方もいらしてました。

* アクシオス使ってみます
    * 是非！
* 自分もブログを運営しているのですが、WordPress を使用しています。ブログといったら WordPress というイメージを持っていたので Chalow やもろもろを使って実装しているとしり驚きました
    * WordPress は PHP & MySQL という構成なので運用がヘビーですよね
    * アップデートをまめにしないと、乗っ取られて攻撃の踏み台とかにされるので注意です

### その他

* 実験場良い✨
    * インフラに興味があるエンジニアは絶対持ったほうが良いです
* バックエンドエンジニアは Vue > Angular > React かも
    * Angular はフルスタックすぎて挫折したなー
* Emacs
    * 一生をともにします
* 自分サーバの紹介おもしろい
    * 意外としている人いなかったか
* setq (setq )
    * Kibana のタグクラウドに出てましたね
* 記事数すごい
    * 初期はホントにメモですので
* 使ってみようと思いました
    * きっかけになれば幸いです
* 面白かったです!!!
    * うれしいです!!!
* もくもく会の成果が出てて良かったです!!
    * やったー!!
* masutaka++
    * これからも◯の数を増やしていきます
* エオルゼアにもいきましょう
    * 今週から復活します！
* "2001年から" → 15年強...！
    * メモが残っているといろいろ便利です
    * 人に説明するとき URL を貼るだけで良いとか
