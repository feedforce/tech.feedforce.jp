---
title: 「今日から始める Go言語 と appengine」というテーマで社内勉強会をしました
date: 2014-03-24 13:08:01
authors: inoue
tags: resume, 
---
<p>はじめまして！DF Plus開発チーム エンジニアの いのうえ と申します。</p>
<p>少し前にはなるのですが、表題のテーマで社内勉強会にて発表をしたので、その資料をこちらでも公開したいと思います。</p>

<!--more-->

<p>弊社での主な開発言語はRubyで、またプラットフォームも CentOS の専用サーバだったり、AWS EC2だったり、なのですが、私が前職で Google App Engine（以下 appengine）メインの仕事をしていたことと、その appengine で使える言語であり、最近異様な盛り上がりを見せてきている言語である、ということで、</p>
<p><b>『Go言語』</b>と<b>『appengine』</b>のふたつをいっきに、私の勉強会のテーマとして取り上げさせて頂きました。（弊社では採用技術ではないものを社内勉強会のテーマとして取り上げたりすることもよくあります^^）</p>
<br/>
<p>と、いう理由は言わば建前で...。</p>
<br/>
<p><b>好きなんです！僕は！appengineが！！</b></p>
<br/>
<p>AWSを触り始めてその楽しさや便利さは日々体験しているところではあるのですが、やはりもっと、appengine が盛り上がってほしいなー、という思いも心の奥底にあります！</p>
<p>と、いうわけで（？）、発表資料のご紹介の前に、まずは内容のダイジェストをご紹介します！</p>

<br/>
<h3>「今日から始める Go言語 と appengine」ダイジェスト</h3>

<h4>Go言語の言語仕様をひと通りご紹介！</h4>
<p>Go言語の言語仕様についてのサイトだと、「<a href="http://tour.golang.org/#1">A Tour of Go</a>」（<a href="http://go-tour-jp.appspot.com/">日本語版</a>）あたりが有名でうまくまとまっていて、しかも実際にテストコードを書いてみて実行してみることも可能なので、<s>もう私の資料なんか見るまでもないんです(｀；ω；´)</s>！</p>
<p>とはいえ、本家では80ページ近くにわたって紹介されているので、もう少し手短に・さらっと知ることができるようにと、私の資料では「A Tour of Go」のうちのエッセンスを抽出し、まとめてみました！</p>

<a href="/images/2014/03/dabdfd03014f4ee861f370df3f4fb105.png"><img src="/images/2014/03/dabdfd03014f4ee861f370df3f4fb105-300x225.png" alt="スクリーンショット 2014-03-17 11.37.25" width="300" height="225" class="alignnone size-medium wp-image-682" /></a>

<h4>こまけぇこたぁいいんだよ！　とにかく「動く」Webアプリを「Goで」書いてみる！</h4>
<p>千里の道も一歩から。「何かしら動くものを作ってみる」ことは、プログラミング言語の習得の近道の一つだと思っています。</p>
<p>ということで今回は、簡単ではありますが「動く」Webアプリを「Goで」、書いてみています。</p>
<p>そのアプリは、はてなが公開しているとあるWebAPIを使って、マッシュアップ的な感じで作ってみています！...さて、どんなアプリなんでしょうか...( ＾ω＾)</p>
<p>もちろんみなさんにも簡単に作ってみてもらうことができます！ぜひトライしてみてください！</p>

<a href="/images/2014/03/d07f48511b92747c913633b367935458.png"><img src="/images/2014/03/d07f48511b92747c913633b367935458-300x224.png" alt="スクリーンショット 2014-03-17 11.37.46" width="300" height="224" class="alignnone size-medium wp-image-683" /></a>

<h4>作ったWebアプリの appengine へのデプロイを、アカウントの取得からご紹介！</h4>
<p>しています！</p>
<p>ところでみなさん、知ってましたか？ appengine は、その利用に際して<b>クレジットカードの登録は不要</b>なんです！（クレカの登録って、心理的障壁としては結構デカイですよね〜(´・ω・｀)）</p>
<p>そして appengine は、最初の登録さえしてしまえばデプロイするのも楽チンです！</p>
<p>この資料では、作成したWebアプリを実際にデプロイ、つまり、<b>そのアプリを全世界に公開してしまう</b>ところまでを、<b>アカウントを取得するところから</b>ご紹介しています！</p>

<a href="/images/2014/03/4393f7062e339c3591fa69bed4395d9f.png"><img src="/images/2014/03/4393f7062e339c3591fa69bed4395d9f-300x224.png" alt="スクリーンショット 2014-03-17 11.38.04" width="300" height="224" class="alignnone size-medium wp-image-684" /></a>

<p>...とまぁ、そんな感じです！</p>
<p>下にあるのが発表資料になります。ぜひみなさんも、Go言語と appengine 、始めてみてくださいね！</p>
<p>（<a href="http://www.slideshare.net/aknow3373/go-appengine?ref=http://tech.feedforce.jp/start-go-and-appengine.html" target="_blank">SlideShare上</a>でご覧頂くと、各ページについての補足・コメント等もご覧頂けます！）</p>

<h3>発表資料</h3>

<iframe src="http://www.slideshare.net/slideshow/embed_code/32362244" width="476" height="400" frameborder="0" marginwidth="0" marginheight="0" scrolling="no"></iframe>