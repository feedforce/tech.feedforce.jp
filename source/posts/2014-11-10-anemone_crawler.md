---
title: Anemoneによるクローラー入門
date: 2014-11-10 10:33 JST
authors: t-nakano
tags: ruby, resume, 
---
<p>こんにちは！<br>
見た目30歳の新卒1年目中野です。<br>
今回は社内でクローラーについて勉強会を行ったので、その内容について記事を書きました。<br>
クローラーとは、WebページからHTMLを解析して周期的に情報を収集する技術です。<br>
初心者向けの内容となっていますので、クローラーに興味があってやってみたい！という人に読んでいただきたいなと思います。</p>

<!--more-->

<iframe src="//www.slideshare.net/slideshow/embed_code/41130757" width="425" height="355" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe> <div style="margin-bottom:5px"> <strong> <a href="//www.slideshare.net/TasukuNakano/anemone-41130757" title="Anemoneによるクローラー入門" target="_blank">Anemoneによるクローラー入門</a> </strong> from <strong><a href="//www.slideshare.net/TasukuNakano" target="_blank">Tasuku Nakano</a></strong> </div>

<h2>クローラーとスクレイピングについて</h2>

<p>まずはクローラーについて説明していきます。<br>
ただ、その前にスクレイピングという技術もあるので先にそちらを説明します。<br>
ご存知かと思いますが、スクレイピングとは、WebページのHTMLをを解析してデータを抽出することです。スクレイピングはWebページ1ページに対して処理を行います。</p>

<p>一方クローラーは、Webページ内にある全てのリンクを巡回して、深堀りしながら目的の情報を取得する方法です。この行為自体はクローリングと呼ばれます。<br>
クローラーでリンクを探す際にはもちろんスクレイピングをしてHTMLのタグを解析して、リンク先を取得します。<br>
クローラーはBotとも呼ばれ、Googleの検索エンジンや画像収集サイトなど様々なサービスで使われています。</p>

<h2>
<span id="anemoneの使い方" class="fragment"></span><a href="https://feedforce.qiita.com/TasukuNakano/items/e5a555e5099f51d2a98f#anemone%E3%81%AE%E4%BD%BF%E3%81%84%E6%96%B9"><i class="fa fa-link"></i></a>Anemoneの使い方</h2>

<p>フィードフォースではRubyを使っており、Rubyでクローリングする方法を紹介します。<br>
(本記事ではRuby2.1.2を使っています。)<br>
クローリングするのに最適なGemとしてAnemoneが参考書(※記事最下部参照)で紹介されていたので、本記事でもAnemoneを使って紹介していきたいと思います。<br>
Anemoneは現在開発が止まっていますが、クローラーの機能として充分網羅されており、多くのユーザに利用されています。</p>

<p>Anemoneの機能としてはざっくり以下のものがあります。</p>

<ul>
<li>階層の制限を指定してたどる</li>
<li>sleep機能でクローリングする間隔を開ける</li>
<li>Webページにアクセスする<a href="http://ja.wikipedia.org/wiki/%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC%E3%82%A8%E3%83%BC%E3%82%B8%E3%82%A7%E3%83%B3%E3%83%88">ユーザエージェント</a>(以下、UA)を指定する</li>
</ul>

<p>それでは実際にAnemoneのメソッドを紹介していきますが、基本的なクローラーの機能は <code>.crawl</code>メソッドでほとんど完結できてしまいます。<br>
<code>.crawl</code>メソッドには様々なオプションを渡せることができ、このオプションによって様々なクローラーの機能を網羅することができます。<br>
では、実際に紹介した機能のオプションをAnemoneの場合に置き換えて紹介します。</p>

<p><code>:depth_limit</code>：階層の制限を指定<br>
<code>:delay</code>：sleep機能(アクセス間隔を指定)<br>
<code>:user_agent</code>：UAを指定</p>

<p>↑で説明した機能以外にもいろいろあります。<br>
指定の仕方としては、<code>.crawl</code>メソッドの第二引数にオプションをHashで渡します(第一引数はURL)<br>
必須ではないので、指定しない場合は<a href="http://www.rubydoc.info/github/chriskite/anemone/Anemone/Core">デフォルト</a>のオプションが使われます。</p>

<p>では、実際にクローリングした後のWebページに対するメソッドについてソースコードと共に紹介していきます。</p>

<h3>
<span id="on_every_pageメソッド" class="fragment"></span><a href="https://feedforce.qiita.com/TasukuNakano/items/e5a555e5099f51d2a98f#on_every_page%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89"><i class="fa fa-link"></i></a>.on_every_pageメソッド</h3>

<p>全てのWebページを対象に処理をするメソッドです。</p>

<div class="code-frame" data-lang="rb"><div class="highlight"><pre><span class="c1"># anemone.rb</span>
<span class="nb">require</span> <span class="s1">'anemone'</span>
<span class="no">URL</span> <span class="o">=</span> <span class="no">ARGV</span><span class="o">[</span><span class="mi">0</span><span class="o">]</span>
<span class="no">Anemone</span><span class="o">.</span><span class="n">crawl</span><span class="p">(</span><span class="no">URL</span><span class="p">,</span> <span class="ss">:depth_limit</span> <span class="o">=&gt;</span> <span class="mi">1</span><span class="p">)</span> <span class="k">do</span> <span class="o">|</span><span class="n">anemone</span><span class="o">|</span>
  <span class="n">anemone</span><span class="o">.</span><span class="n">on_every_page</span> <span class="k">do</span> <span class="o">|</span><span class="n">page</span><span class="o">|</span>
    <span class="nb">puts</span> <span class="n">page</span><span class="o">.</span><span class="n">url</span>
  <span class="k">end</span>
<span class="k">end</span>
</pre></div></div>

<p>まず、URLを引数として受け取るようにしました。<br>
ここでは階層を1に指定したので、リンクからたどる回数は1になります。<br>
数を多くするとそれだけ実行に時間がかかってしてしまうため、1としました。<br>
その後にブロック引数として渡した<code>page</code>に、取得したWebページの情報が入っています。<br>
そこで<code>.url</code>メソッドを使うことによってURLを取得できます。</p>

<p>実行する際にはターミナルで<br>
<code>$ ruby anemone.rb http://tech.feedforce.jp/</code><br>
とすると、このリンク先にから辿れるリンク一覧と、更にその一覧からたどった先のリンク一覧を表示することができます。<br>
「<a href="/">http://tech.feedforce.jp/</a> 」以外から取得したい場合はURLを変えると違うページからでもリンク一覧を取得できると思います。<br>
ただ、リンクが多いサイトでは実行に時間がかかってしまいますので、注意するようにしてください。</p>

<h3>
<span id="on_pages_likeメソッド" class="fragment"></span><a href="https://feedforce.qiita.com/TasukuNakano/items/e5a555e5099f51d2a98f#on_pages_like%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89"><i class="fa fa-link"></i></a>.on_pages_likeメソッド</h3>

<p>ただ、先ほどのメソッドを実装してしまうと大変なので、指定したページのみ処理するようにしたいとおもいます。<br>
指定したページのみを対象に処理するメソッドです。</p>

<p>では、実際にソースコードで実装していきましょう。<br>
対象はフィードフォースのブログで、以下の記事としました。</p>

<ul>
<li><a href="/lego-scrum.html">「LEGO(R)ではじめるスクラム入門」に参加してきました</a></li>
<li><a href="/summer_intern2014.html">フィードフォースで初めてエンジニア向けサマーインターンをやってみた</a></li>
<li><a href="/agile_whiteboards.html">アジャイル開発で便利だったホワイトボードなどまとめ</a></li>
</ul>

<div class="code-frame" data-lang="rb"><div class="highlight"><pre><span class="c1"># anemone2.rb</span>
<span class="nb">require</span> <span class="s1">'anemone'</span>
<span class="no">URL</span> <span class="o">=</span> <span class="no">ARGV</span><span class="o">[</span><span class="mi">0</span><span class="o">]</span>

<span class="no">Anemone</span><span class="o">.</span><span class="n">crawl</span><span class="p">(</span><span class="no">URL</span><span class="p">,</span> <span class="ss">depth_limit</span><span class="p">:</span> <span class="mi">2</span><span class="p">)</span> <span class="k">do</span> <span class="o">|</span><span class="n">anemone</span><span class="o">|</span>
  <span class="no">PATTERN</span> <span class="o">=</span> <span class="sr">%r[lego-scrum.html|summer_intern2014.html|agile_whiteboards.html]</span>

  <span class="n">anemone</span><span class="o">.</span><span class="n">on_pages_like</span><span class="p">(</span><span class="no">PATTERN</span><span class="p">)</span> <span class="k">do</span> <span class="o">|</span><span class="n">page</span><span class="o">|</span>
    <span class="nb">puts</span> <span class="n">page</span><span class="o">.</span><span class="n">url</span>
  <span class="k">end</span>
<span class="k">end</span>
</pre></div></div>

<p><code>.on_pages_like</code>メソッドでは、引数に正規表現を渡すことで対象を絞ることができます。<br>
今回は、対象としている記事のURLを直接指定するように実装しています。<br>
この意図としては例えば「page=1」,「page=2」…というように続く場合には正規表現で<br>
<code>%r[page=\d+]</code>とすれば良いのですが、今回は特にそういったパターンには当てはまらないので、直接指定しました。<br>
Webページを指定して取得できたらあとは、anemone.rbと同様に<code>.url</code>メソッドを呼ぶことでURLを取得することができます。</p>

<h2>
<span id="各記事の項目一覧を取得する" class="fragment"></span><a href="https://feedforce.qiita.com/TasukuNakano/items/e5a555e5099f51d2a98f#%E5%90%84%E8%A8%98%E4%BA%8B%E3%81%AE%E9%A0%85%E7%9B%AE%E4%B8%80%E8%A6%A7%E3%82%92%E5%8F%96%E5%BE%97%E3%81%99%E3%82%8B"><i class="fa fa-link"></i></a>各記事の項目一覧を取得する</h2>

<p>ここではページのurlのみを取得するような処理を紹介しましたが、実際に細かな情報を取得したいこともあります。</p>

<p>そこで最初に説明したスクレイピングを行っていきます。<br>
スクレイピングを行う上で扱うGemは皆さんご存知のNokogiriを使います。</p>

<p>その前に、スクレイピングを行う上でも知っておくと便利な知識があるので紹介したいと思います。</p>

<p>それはXPathというものがあります。<br>
XPathはHTMLをXML文書として、階層構造で特定部分を示すための構文です。<br>
XPathを使わずに正規表現を使って情報を抜き出すことも可能ですが、かなり手間がかかるためXPathを使うことをおすすめします。<br>
記法としてはHTMLを木構造としてみて、探し当てたいノードに一番近いルートのタグからたどって表記します。<br>
例えば、<a href="/summer_intern2014.html">ここ</a>のタイトルである「フィードフォースで初めてサマーインターンをやってみた」のXPathは<code>//*[@id="content"]/article/div[1]/h1</code>となります。</p>

<p>XPathの取得方法は文章で書くよりもスライドの方がわかりやすいと思うので、スライドの35ページ辺りを参考にしてみてください。</p>

<p>では、XPathを使ってスクレイピングをしてみましょう。<br>
スクレイピング対象は変わらず先ほどのURLと同じこのエンジニアブログにします。<br>
ここから、各記事内の項目一覧を取得します。</p>

<div class="code-frame" data-lang="rb"><div class="highlight"><pre><span class="c1"># anemone3.rb</span>
<span class="nb">require</span> <span class="s1">'anemone'</span>
<span class="nb">require</span> <span class="s1">'nokogiri'</span>
<span class="nb">require</span> <span class="s1">'kconv'</span>

<span class="no">URL</span> <span class="o">=</span> <span class="no">ARGV</span><span class="o">[</span><span class="mi">0</span><span class="o">]</span>
<span class="no">Anemone</span><span class="o">.</span><span class="n">crawl</span><span class="p">(</span><span class="no">URL</span><span class="p">,</span><span class="ss">:depth_limit</span> <span class="o">=&gt;</span> <span class="mi">1</span><span class="p">)</span> <span class="k">do</span> <span class="o">|</span><span class="n">anemone</span><span class="o">|</span>
  <span class="no">PATTERN</span> <span class="o">=</span> <span class="sr">%r[lego-scrum.html|summer_intern2014.html|agile_whiteboards.html]</span>

  <span class="n">anemone</span><span class="o">.</span><span class="n">focus_crawl</span> <span class="k">do</span> <span class="o">|</span><span class="n">page</span><span class="o">|</span>
    <span class="n">page</span><span class="o">.</span><span class="n">links</span><span class="o">.</span><span class="n">keep_if</span><span class="p">{</span> <span class="o">|</span><span class="n">link</span><span class="o">|</span>
      <span class="n">link</span><span class="o">.</span><span class="n">to_s</span><span class="o">.</span><span class="n">match</span><span class="p">(</span><span class="no">PATTERN</span><span class="p">)</span>
    <span class="p">}</span>
  <span class="k">end</span>

  <span class="n">anemone</span><span class="o">.</span><span class="n">on_every_page</span> <span class="k">do</span> <span class="o">|</span><span class="n">page</span><span class="o">|</span>
    <span class="n">doc</span> <span class="o">=</span> <span class="no">Nokogiri</span><span class="o">::</span><span class="no">HTML</span><span class="o">.</span><span class="n">parse</span><span class="p">(</span><span class="n">page</span><span class="o">.</span><span class="n">body</span><span class="o">.</span><span class="n">toutf8</span><span class="p">)</span>
    <span class="n">body</span> <span class="o">=</span> <span class="n">doc</span><span class="o">.</span><span class="n">xpath</span><span class="p">(</span><span class="sx">%Q[//*[@id="content"]/article/div[3]]</span><span class="p">)</span>

    <span class="n">body</span><span class="o">.</span><span class="n">css</span><span class="p">(</span><span class="s1">'h2'</span><span class="p">)</span><span class="o">.</span><span class="n">each</span> <span class="k">do</span> <span class="o">|</span><span class="n">h2</span><span class="o">|</span>
      <span class="nb">puts</span> <span class="n">h2</span><span class="o">.</span><span class="n">text</span>
    <span class="k">end</span>
  <span class="k">end</span>
<span class="k">end</span>
</pre></div></div>

<p>まず、パターンマッチでスクレイピング対象となるhtmlを絞ります。<br>
ここで、対象を絞り込んだ後に<code>.css</code>や<code>.text</code>というメソッドを使っています。<br>
これらは、NokogiriのNodeオブジェクトが持っているメソッドになります。</p>

<p>スクレイピングするにあたってはこのNodeオブジェクトについて理解することが大切になってくるのですが、この説明だけで1つの記事をかけてしまうくらいのものなので割愛させていただきます。<br>
スライドに簡単に説明を加えてありますので、そちらを参照ください。</p>

<h2>
<span id="クロールする上でのルール" class="fragment"></span><a href="https://feedforce.qiita.com/TasukuNakano/items/e5a555e5099f51d2a98f#%E3%82%AF%E3%83%AD%E3%83%BC%E3%83%AB%E3%81%99%E3%82%8B%E4%B8%8A%E3%81%A7%E3%81%AE%E3%83%AB%E3%83%BC%E3%83%AB"><i class="fa fa-link"></i></a>クロールする上でのルール</h2>

<p>最後に、クロールする上でルールがあるので紹介します。<br>
クローラーは対象のWebサイトに頻繁にアクセスをしますので、攻撃とみなされてしまうことがあります。<br>
また、収集した情報を許可なくそのまま公開してしまうと、著作権違反で捕まってしまうこともあります。</p>

<p>また、UAを指定してこのUAからはクローリングされたくないなどWebサイトで決め事をしていることもあります。<br>
この決め事をしているのをまとめて公開しているものがあり、それがrobots.txtです。<br>
以下に、robots.txtの記述方式をまとめておきます。</p>

<h3>
<span id="robotstxtの記述方式" class="fragment"></span><a href="https://feedforce.qiita.com/TasukuNakano/items/e5a555e5099f51d2a98f#robotstxt%E3%81%AE%E8%A8%98%E8%BF%B0%E6%96%B9%E5%BC%8F"><i class="fa fa-link"></i></a>robots.txtの記述方式</h3>

<p>User-agent: ルールを適用したいUA<br>
Allow: クロールの可能なページのパス<br>
Disallow: クロールされたくないページのパス<br>
Crawl-delay: クロール間隔(単位はあやふや)</p>

<p>またrubyには、robots.txtをよしなに処理してくれるrubyのgemとして<a href="https://github.com/chriskite/robotex">robotex</a>があります。<br>
そこまで使い方は難しくないので、説明は割愛させていただきます。</p>

<p>以下に、実際に使われているrobots.txtを紹介します</p>

<ul>
<li><a href="http://www.amazon.com/robots.txt">Amazon</a></li>
<li><a href="http://hatenablog.com/robots.txt">はてなブログ</a></li>
<li><a href="http://ja.wikipedia.org/robots.txt">Wikipedia</a></li>
</ul>

<p>例えば、はてなブログから新着記事のタイトルをクローリングする際には、<a href="http://hatenablog.com/robots.txt">http://hatenablog.com/robots.txt</a> のルールを守るように心がけてください。</p>

<h2>
<span id="参考書の紹介" class="fragment"></span><a href="https://feedforce.qiita.com/TasukuNakano/items/e5a555e5099f51d2a98f#%E5%8F%82%E8%80%83%E6%9B%B8%E3%81%AE%E7%B4%B9%E4%BB%8B"><i class="fa fa-link"></i></a>参考書の紹介</h2>

<p>最後に今回、クローラーを勉強するにあたって以下の本を参考にさせていただきました。<br>
クローラーに関する基礎から応用まで網羅されていて、とても良書でした。<br>
本記事を読んで、クローラーに興味を持っていただけたら、読んでみてください。<br>
<a href="http://www.amazon.co.jp/dp/4797380357"><img src="/images/2014/11/9f581f9b7f4046c18983b6c479aa7c3f.jpeg"></a></p>

<p>みなさん安全に楽しくクローリング生活を楽しんでいただけたらと思います！<br>
以上です。ありがとうございました。</p>
