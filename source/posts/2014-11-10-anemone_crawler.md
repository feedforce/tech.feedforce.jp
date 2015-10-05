---
title: Anemoneによるクローラー入門
date: 2014-11-10 10:33 JST
authors: t-nakano
tags: ruby, resume,
---
こんにちは！
見た目30歳の新卒1年目中野です。
今回は社内でクローラーについて勉強会を行ったので、その内容について記事を書きました。
クローラーとは、WebページからHTMLを解析して周期的に情報を収集する技術です。
初心者向けの内容となっていますので、クローラーに興味があってやってみたい！という人に読んでいただきたいなと思います。

<!--more-->

<iframe src="//www.slideshare.net/slideshow/embed_code/41130757" width="425" height="355" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe>
 **[Anemoneによるクローラー入門](//www.slideshare.net/TasukuNakano/anemone-41130757 "Anemoneによるクローラー入門")** from **[Tasuku Nakano](//www.slideshare.net/TasukuNakano)**

## クローラーとスクレイピングについて

まずはクローラーについて説明していきます。
ただ、その前にスクレイピングという技術もあるので先にそちらを説明します。
ご存知かと思いますが、スクレイピングとは、WebページのHTMLをを解析してデータを抽出することです。スクレイピングはWebページ1ページに対して処理を行います。

一方クローラーは、Webページ内にある全てのリンクを巡回して、深堀りしながら目的の情報を取得する方法です。この行為自体はクローリングと呼ばれます。
クローラーでリンクを探す際にはもちろんスクレイピングをしてHTMLのタグを解析して、リンク先を取得します。
クローラーはBotとも呼ばれ、Googleの検索エンジンや画像収集サイトなど様々なサービスで使われています。

## Anemoneの使い方

フィードフォースではRubyを使っており、Rubyでクローリングする方法を紹介します。
(本記事ではRuby2.1.2を使っています。)
クローリングするのに最適なGemとしてAnemoneが参考書(※記事最下部参照)で紹介されていたので、本記事でもAnemoneを使って紹介していきたいと思います。
Anemoneは現在開発が止まっていますが、クローラーの機能として充分網羅されており、多くのユーザに利用されています。

Anemoneの機能としてはざっくり以下のものがあります。

- 階層の制限を指定してたどる
- sleep機能でクローリングする間隔を開ける
- Webページにアクセスする [ユーザエージェント](http://ja.wikipedia.org/wiki/%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC%E3%82%A8%E3%83%BC%E3%82%B8%E3%82%A7%E3%83%B3%E3%83%88)(以下、UA)を指定する

それでは実際にAnemoneのメソッドを紹介していきますが、基本的なクローラーの機能は `.crawl`メソッドでほとんど完結できてしまいます。

`.crawl`メソッドには様々なオプションを渡せることができ、このオプションによって様々なクローラーの機能を網羅することができます。
では、実際に紹介した機能のオプションをAnemoneの場合に置き換えて紹介します。

`:depth_limit`：階層の制限を指定

`:delay`：sleep機能(アクセス間隔を指定)

`:user_agent`：UAを指定

↑で説明した機能以外にもいろいろあります。
指定の仕方としては、`.crawl`メソッドの第二引数にオプションをHashで渡します(第一引数はURL)
必須ではないので、指定しない場合は [デフォルト](http://www.rubydoc.info/github/chriskite/anemone/Anemone/Core)のオプションが使われます。

では、実際にクローリングした後のWebページに対するメソッドについてソースコードと共に紹介していきます。

### .on\_every\_pageメソッド

全てのWebページを対象に処理をするメソッドです。

```
# anemone.rbrequire 'anemone'URL = ARGV[0]Anemone.crawl(URL, :depth_limit => 1) do |anemone|
  anemone.on_every_page do |page|
    puts page.url
  endend
```

まず、URLを引数として受け取るようにしました。
ここでは階層を1に指定したので、リンクからたどる回数は1になります。
数を多くするとそれだけ実行に時間がかかってしてしまうため、1としました。
その後にブロック引数として渡した`page`に、取得したWebページの情報が入っています。
そこで`.url`メソッドを使うことによってURLを取得できます。

実行する際にはターミナルで

`$ ruby anemone.rb http://tech.feedforce.jp/`
とすると、このリンク先にから辿れるリンク一覧と、更にその一覧からたどった先のリンク一覧を表示することができます。
「 [http://tech.feedforce.jp/](http://tech.feedforce.jp/) 」以外から取得したい場合はURLを変えると違うページからでもリンク一覧を取得できると思います。
ただ、リンクが多いサイトでは実行に時間がかかってしまいますので、注意するようにしてください。

### .on\_pages\_likeメソッド

ただ、先ほどのメソッドを実装してしまうと大変なので、指定したページのみ処理するようにしたいとおもいます。
指定したページのみを対象に処理するメソッドです。

では、実際にソースコードで実装していきましょう。
対象はフィードフォースのブログで、以下の記事としました。

- [「LEGO(R)ではじめるスクラム入門」に参加してきました](http://tech.feedforce.jp/lego-scrum.html)
- [フィードフォースで初めてエンジニア向けサマーインターンをやってみた](http://tech.feedforce.jp/summer_intern2014.html)
- [アジャイル開発で便利だったホワイトボードなどまとめ](http://tech.feedforce.jp/agile_whiteboards.html)

```
# anemone2.rbrequire 'anemone'URL = ARGV[0]

Anemone.crawl(URL, depth_limit: 2) do |anemone|
  PATTERN = %r[lego-scrum.html|summer_intern2014.html|agile_whiteboards.html]

 anemone.on_pages_like(PATTERN) do |page|
    puts page.url
  endend
```

`.on_pages_like`メソッドでは、引数に正規表現を渡すことで対象を絞ることができます。
今回は、対象としている記事のURLを直接指定するように実装しています。
この意図としては例えば「page=1」,「page=2」…というように続く場合には正規表現で

`%r[page=\d+]`とすれば良いのですが、今回は特にそういったパターンには当てはまらないので、直接指定しました。
Webページを指定して取得できたらあとは、anemone.rbと同様に`.url`メソッドを呼ぶことでURLを取得することができます。

## 各記事の項目一覧を取得する

ここではページのurlのみを取得するような処理を紹介しましたが、実際に細かな情報を取得したいこともあります。

そこで最初に説明したスクレイピングを行っていきます。
スクレイピングを行う上で扱うGemは皆さんご存知のNokogiriを使います。

その前に、スクレイピングを行う上でも知っておくと便利な知識があるので紹介したいと思います。

それはXPathというものがあります。
XPathはHTMLをXML文書として、階層構造で特定部分を示すための構文です。
XPathを使わずに正規表現を使って情報を抜き出すことも可能ですが、かなり手間がかかるためXPathを使うことをおすすめします。
記法としてはHTMLを木構造としてみて、探し当てたいノードに一番近いルートのタグからたどって表記します。
例えば、 [ここ](http://tech.feedforce.jp/summer_intern2014.html)のタイトルである「フィードフォースで初めてサマーインターンをやってみた」のXPathは`//*[@id="content"]/article/div[1]/h1`となります。

XPathの取得方法は文章で書くよりもスライドの方がわかりやすいと思うので、スライドの35ページ辺りを参考にしてみてください。

では、XPathを使ってスクレイピングをしてみましょう。
スクレイピング対象は変わらず先ほどのURLと同じこのエンジニアブログにします。
ここから、各記事内の項目一覧を取得します。

```
# anemone3.rbrequire 'anemone'require 'nokogiri'require 'kconv'

URL = ARGV[0]Anemone.crawl(URL,:depth_limit => 1) do |anemone|
  PATTERN = %r[lego-scrum.html|summer_intern2014.html|agile_whiteboards.html]

 anemone.focus_crawl do |page|
    page.links.keep_if{ |link|
      link.to_s.match(PATTERN)
    }
  end

 anemone.on_every_page do |page|
    doc = Nokogiri::HTML.parse(page.body.toutf8)
    body = doc.xpath(%Q[//*[@id="content"]/article/div[3]])

 body.css('h2').each do |h2|
      puts h2.text
    end
  endend
```

まず、パターンマッチでスクレイピング対象となるhtmlを絞ります。
ここで、対象を絞り込んだ後に`.css`や`.text`というメソッドを使っています。
これらは、NokogiriのNodeオブジェクトが持っているメソッドになります。

スクレイピングするにあたってはこのNodeオブジェクトについて理解することが大切になってくるのですが、この説明だけで1つの記事をかけてしまうくらいのものなので割愛させていただきます。
スライドに簡単に説明を加えてありますので、そちらを参照ください。

## クロールする上でのルール

最後に、クロールする上でルールがあるので紹介します。
クローラーは対象のWebサイトに頻繁にアクセスをしますので、攻撃とみなされてしまうことがあります。
また、収集した情報を許可なくそのまま公開してしまうと、著作権違反で捕まってしまうこともあります。

また、UAを指定してこのUAからはクローリングされたくないなどWebサイトで決め事をしていることもあります。
この決め事をしているのをまとめて公開しているものがあり、それがrobots.txtです。
以下に、robots.txtの記述方式をまとめておきます。

### robots.txtの記述方式

User-agent: ルールを適用したいUA
Allow: クロールの可能なページのパス
Disallow: クロールされたくないページのパス
Crawl-delay: クロール間隔(単位はあやふや)

またrubyには、robots.txtをよしなに処理してくれるrubyのgemとして [robotex](https://github.com/chriskite/robotex)があります。
そこまで使い方は難しくないので、説明は割愛させていただきます。

以下に、実際に使われているrobots.txtを紹介します

- [Amazon](http://www.amazon.com/robots.txt)
- [はてなブログ](http://hatenablog.com/robots.txt)
- [Wikipedia](http://ja.wikipedia.org/robots.txt)

例えば、はてなブログから新着記事のタイトルをクローリングする際には、 [http://hatenablog.com/robots.txt](http://hatenablog.com/robots.txt) のルールを守るように心がけてください。

## 参考書の紹介

最後に今回、クローラーを勉強するにあたって以下の本を参考にさせていただきました。
クローラーに関する基礎から応用まで網羅されていて、とても良書でした。
本記事を読んで、クローラーに興味を持っていただけたら、読んでみてください。

[![](/images/2014/11/9f581f9b7f4046c18983b6c479aa7c3f.jpeg)](http://www.amazon.co.jp/dp/4797380357)

みなさん安全に楽しくクローリング生活を楽しんでいただけたらと思います！
以上です。ありがとうございました。

