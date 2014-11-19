---
title: ShindigとPartuzaでOpenSocialガジェットのテスト環境を構築(その1)
date: 2008-10-06 10:59:23
authors: fukunaga
tags: resume, 
---
<p><a href="http://code.google.com/apis/opensocial/">OpenSocial</a>対応のガジェットを構築するうえでの悩みどころは、「テスト環境どうするの？」というところではないでしょうか。</p>

<p>まだ公開していないガジェットアプリケーションを<a href="http://www.orkut.com/">Orkut</a>のsandboxでテストするのはちょっとなぁ・・・と思ったことがある人は、ここで紹介するShindigとPartuzaを使ってみるといいかもしれません。</p>

<p>今回はまず Shindig について説明します。</p>
<!--more-->
<h2>Shindig</h2>

<p><a href="http://incubator.apache.org/shindig/">Shindig</a>は<a href="http://code.google.com/apis/opensocial/docs/0.8/spec.html">OpenSocial API Specification</a>と<a href="http://code.google.com/apis/gadgets/docs/spec.html">Gadgets Specification</a>を実装したオープンソースのプロジェクトです。<a href="http://incubator.apache.org/">Apache incubator</a>にて開発が進められています。</p>

<p>Shindigを使うと誰でも自由にOpenSocialガジェットをホストするサイトを構築することができます。ローカル環境に立てればテスト環境が作れるというわけです。</p>

<p>※ iGoogleのガジェットをいくつか試してみましたが、すべてのガジェットが実行できるわけではありませんでした。iGoogle独自のメソッドの多くは実装されていないようです。</p>

<h3>Shindigの構成要素</h3>

<ul>
<li>Gadget Container JavaScript</li>
<li>Gadget Server</li>
<li>OpenSocial Container JavaScript</li>
<li>OpenSocial Data Server</li>
</ul>

<h3>導入</h3>

<p><a href="http://incubator.apache.org/shindig/#php" class="external">http://incubator.apache.org/shindig/#php</a></p>

<p>Java版もありますが、ここではPHP版で。</p>

<h4>必要環境</h4>

<ul>
<li>Subversion</li>
<li>mod_rewrite</li>
<li>PHP 5.2.x (json, simplexml, mcrypt, curl)</li>
</ul>

<h4>ソースをチェックアウト</h4>

<pre><code>$ mkdir /var/www/shindig
$ cd /var/www/shindig
$ svn co http://svn.apache.org/repos/asf/incubator/shindig/trunk/ .</code></pre>

<h4>バーチャルホストを立てる</h4>

<p>ここでは dev.shindig.jp というドメインとします。</p>

<pre><code>&lt;VirtualHost 192.168.1.142:80&gt;
    DocumentRoot /var/www/shindig/php
    DirectoryIndex index.html index.php
    ServerName dev.shindig.jp
    AddDefaultCharset UTF-8 

    &lt;Directory /var/www/shindig/php&gt;
        AllowOverride All
    &lt;/Directory&gt; 
&lt;/VirtualHost&gt;</code></pre>

<h4>PECL json インストール</h4>

<p>個人の環境にPECL jsonが入っていなかったのでインストールしました。</p>

<pre><code>$ sudo pecl install json</code></pre>

<h3>ガジェットを実行してみる</h3>

<p>ここまでできれば、すぐにガジェットを実行することができます。エンドポイントは、</p>

<pre><code>http://dev.shindig.jp/gadgets/ifr?</code></pre>

<p>です。urlパラメータを与えてガジェットを実行します。</p>

<pre><code>http://dev.shindig.jp/gadgets/ifr?url=[ガジェットのXMLファイルのURL]</code></pre>

<p><img src='/images/2008/09/shindig-example.gif' alt='shindig-example.gif' /></p>

<p>↑ ドキュメントに<a href="http://www.labpixies.com/campaigns/todo/todo.xml">サンプルとして記載されているガジェット</a>を実行したところ。</p>

<p>このように、Shindigを使うと簡単にOpenSocial対応ガジェットをホスティングする環境を作ることができます。</p>

<p>というわけで、次回はPartuzaについて。</p>
