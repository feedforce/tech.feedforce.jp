---
title: feedforceで使っている開発ツールたち(Slackはじめました)
date: 2014-10-24 15:19:49
authors: r-suzuki
tags: dev_style, 
---
<p>こんにちは。漫画「GIANT KILLING」に最近ハマっている鈴木です。(チームビルディング厨)<br>
今日は弊社feedforceのエンジニアが使っている開発ツールたちをご紹介します。</p>

<!--more-->

<h2>
<span id="開発マシン-エディタ" class="fragment"></span><a href="#%E9%96%8B%E7%99%BA%E3%83%9E%E3%82%B7%E3%83%B3-%E3%82%A8%E3%83%87%E3%82%A3%E3%82%BF"><i class="fa fa-link"></i></a>開発マシン, エディタ</h2>

<p>「開発マシンのOS自由」としていますが、結果として現在のメンバーは全員Mac。<br>
ディスクやメモリに余裕が欲しいので Mac mini + デュアルモニタという構成にしています。</p>

<p>メインとして使っているエディタの勢力分布は以下のとおりです。</p>

<ul>
<li>Vim: 6</li>
<li>Emacs: 3</li>
<li>Sublime: 2</li>
<li>Rubymine: 1</li>
<li>Atom: 1</li>
</ul>

<p>「ペアプロするときは相手のエディタを使ってみる」という穏和な関係を保っています。</p>

<img src="/images/2014/10/IMG_2109-1024x768.jpg" alt="IMG_2109" width="1024" height="768" class="aligncenter size-large wp-image-1092" />

<h2>
<span id="バージョン管理ci" class="fragment"></span><a href="#%E3%83%90%E3%83%BC%E3%82%B8%E3%83%A7%E3%83%B3%E7%AE%A1%E7%90%86ci"><i class="fa fa-link"></i></a>バージョン管理、CI</h2>

<p>以前このブログに<a href="http://tech.feedforce.jp/2014-employ-a-month.html">Subversionだった (ﾟдﾟ；) 的な記事</a>がありましたが、現在はGitに移行してGitHub(Organizationプラン)を利用。GitHub Flowに従い、プルリクエスト→レビュー→マージ→デプロイという流れで開発しています。</p>

<p>CIはJenkinsがメインですが、CircleCIを使い始めました。クラウドサービスに移行して社内サーバーを減らしているところです。</p>

<h2>
<span id="コラボレーション" class="fragment"></span><a href="#%E3%82%B3%E3%83%A9%E3%83%9C%E3%83%AC%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3"><i class="fa fa-link"></i></a>コラボレーション</h2>

<p>メンバー間のコミュニケーション、コラボレーションツールとしてQiita:TeamとSlackを使っています。<br>
これはエンジニアだけでなく全社員(代表や営業も含む40人弱)で、職種の垣根なくコミュニケーションをとるためです。</p>

<p>Qiita:Teamでは日報による日々の情報共有に始まり、開発に関するノウハウや新サービスのアイディアなどが投稿されています。「自分用」を装いつつ有益な情報をシェアする「俺のメモ」タグが人気です。</p>

<img src="/images/2014/10/qiita-team-1024x645.png" alt="qiita-team" width="1024" height="645" class="aligncenter size-large wp-image-1090" />

<p>チャットツールはHipChatを使っていましたが、未読管理や視認性のよさ(アイコン表示など)からSlackに今週乗り換えました。</p>

<h2>
<span id="おわりに" class="fragment"></span><a href="#%E3%81%8A%E3%82%8F%E3%82%8A%E3%81%AB"><i class="fa fa-link"></i></a>おわりに</h2>

<p>というわけで弊社で使っている開発ツールを紹介しました。新しいツールの導入は、社内で開催しているブラウンバッグミーティングや「もくもく会」でのアイディアをきっかけに試用を始め、感触を確かめながら全社に広めていくというパターンが多いです。</p>

<p>また、こういったツールを活用しつつ一緒に<a href="http://www.feedforce.jp/service/">feedforceのプロダクト</a>を開発してくれる仲間を募集中です！ご興味ある方はお気軽にお問い合わせ、または<a href="http://tech.feedforce.jp/member">メンバー</a>にお声かけください。お待ちしています。</p>
