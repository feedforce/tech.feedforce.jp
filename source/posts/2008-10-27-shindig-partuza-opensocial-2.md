---
title: ShindigとPartuzaでOpenSocialガジェットのテスト環境を構築(その2)
date: 2008-10-27 11:07:36
authors: fukunaga
tags: resume, 
---
前回はOpenSocialガジェットのホスティング環境を構築できる <a href="http://incubator.apache.org/shindig/">Shindig</a> について説明しました。

» <a href="http://tech.feedforce.jp/shindig-partuza-opensocial-1.html">FFTT : ShindigとPartuzaでOpenSocialガジェットのテスト環境を構築(その1)</a>

今回は、その Shindig を利用して OpenSocial 機能を実装している <a href="http://www.partuza.nl/">Partuza</a> を紹介します。
<!--more-->
<h2>Partuza</h2>
<a href="http://www.partuza.nl/">Partuza</a> はオープンソースのSNSです。PHPで書かれています。読み方はよくわかりません。ソースをダウンロードして個人の環境に設置することで使えるようになります。ライセンスは Apache License 2.0 です。
<h3>こんなとき参考になります</h3>
<ul>
	<li>Apache Shindigを利用してOpen Social対応SNSを作りたい</li>
	<li>すでにあるSNSにApache Shindigを利用したOpen Social機能を実装したい</li>
</ul>
というわけで、早速 Partuza をインストールしてみます。ソースコードは <a href="http://code.google.com/p/partuza/">partuza - Google Code</a> から入手できます。
<h3>Partuza のインストール</h3>
<h4>checkout</h4>
<pre><code>$ mkdir /var/www/partuza
$ cd /var/www/partuza
$ svn co http://partuza.googlecode.com/svn/trunk .</code></pre>
<h4>バーチャルホストを設定</h4>
<pre><code>&lt;VirtualHost 192.168.1.142:80&gt;
    DocumentRoot /var/www/partuza/html
    ServerName dev.partuza.jp
    ErrorLog /var/log/httpd/partuza_error_log
    CustomLog /var/log/httpd/partuza_access_log combined

    AddDefaultCharset UTF-8

    &lt;Directory /var/www/partuza/html&gt;
        AllowOverride All
    &lt;/Directory&gt;
&lt;/VirtualHost&gt;</code></pre>
<h4>必要であれば</h4>
/etc/php.ini に以下の記述があるか。
<pre><code>short_open_tag = On</code></pre>
<a href="http://www.libgd.org/Main_Page">gd</a>をインストールしていなければインストール。
<h4>パーミッション変更</h4>
<pre><code>$ chmod 777 /var/www/partuza/images/people</code></pre>
<h4>SQL実行(MySQL)</h4>
<pre><code>$ cd /var/www/partuza
$ mysqladmin -u root -p create partuza
$ mysql -u root -p -D partuza &lt; partuza.sql</code></pre>
ここまで設定すれば、Partuza が動きます。

しかし、まだ Shindig が組み込まれていませんので、Shindig を Partuza に組み込む設定をします。
<h4>Shindig に local.php を作成</h4>
<pre><code>$ vi /var/www/shindig/config/local.php</code></pre>
local.phpファイルの中身は次のようにする。
<pre><code>&lt;?php

$shindigConfig = array(
                       'people_service' =&gt; 'PartuzaPeopleService',
                       'activity_service' =&gt; 'PartuzaActivitiesService',
                       'app_data_service' =&gt; 'PartuzaAppDataService',
                       'extension_class_paths' =&gt; '/var/www/partuza/Shindig',);</code></pre>
<h4>Partuza の config.php を編集</h4>
Shindig が動く環境のホスト名を設定します。
<pre><code>$ vi /var/www/partuza/html/config.php</code></pre>
<pre><code>- 'gadget_server'    =&gt; 'http://shindig',
+ 'gadget_server'    =&gt; 'http://dev.shindig.jp',</code></pre>
ここまで設定できれば、PartuzaでOpenSocialガジェットが動くようになります。

<img src="/images/2008/10/partuza-home.gif" alt="Partuza" />

↑ テストで<a href="http://www.google.co.jp/ig/directory?hl=ja&amp;url=map.fkoji.com/kusayakyu/search.xml">このガジェット</a>を追加してみました。(※ このガジェットにOpenSocialの機能はありません。)
<h2>まとめ</h2>
このように、 Shindig と Partuza を利用すると、OpenSocial対応のガジェットおよびSNSの開発環境を簡単に構築することができます。興味のある方はぜひ利用してみてください。

» <a href="http://tech.feedforce.jp/shindig-partuza-opensocial-1.html">FFTT : ShindigとPartuzaでOpenSocialガジェットのテスト環境を構築(その1)</a>
