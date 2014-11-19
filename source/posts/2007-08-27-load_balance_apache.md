---
title: 負荷分散講習会 Apache編
date: 2007-08-27 14:23:02
authors: akahige
tags: infrastructure, resume, 
---

  <div class="day">
  <h2><span class="date"><a name="l0"> </a></span><span class="title">ゴール</span></h2>
  <div class="body">
    <div class="section">
      <ul>
<li>負荷分散のいくつかの方法に関して理解する</li>
<li>mod_proxy_balancerによる負荷分散クラスタが構築できる</li>
</ul>

    </div>
  </div>
</div>
<!--more-->
<div class="day">
  <h2><span class="date"><a name="l1"> </a></span><span class="title">基礎知識編</span></h2>
  <div class="body">
    <div class="section">
      <h3><a name="l2"><span class="sanchor"> </span></a>基本的な資料</h3>

<p>主にクラスタによる負荷分散の資料。</p>
<ul>
<li><a href="http://httpd.apache.org/docs/2.2/ja/mod/mod_proxy_balancer.html" class="external">Apache モジュール mod_proxy_balancer</a></li>
<li><a href="http://www.onflow.jp/blog/archives/2006/02/mod_proxy_balan.html" class="external">mod_proxy_balancerで中?大規模サーバー運用するときの勘所 - cyano</a></li>
</ul>
<p>あと社外秘資料。</p>
<h3><a name="l3"><span class="sanchor"> </span></a>負荷分散？</h3>
<p>複数台のサーバにアクセスを分散して、個々のサーバにかかる負荷を減らし、全体的に処理できるアクセスを増やすこと。</p>
<p>以下のようなアプローチがある。</p>

<h4><a name="l4"> </a>DNSラウンドロビン</h4>
<ul>
<li>DNSでひとつのホスト名に複数のIPアドレスを割り当てる方法</li>
<li>シンプル</li>
<li>しかしダウンしているホストにもアクセスが振り分けされてしまう<ul>
<li>冗長化と併用でなんとかなるかな？</li>
</ul></li>
</ul>
<h4><a name="l5"> </a>機能ごとにホストを分割</h4>

<ul>
<li>ウェブサーバとDBサーバの分割（基本過ぎるが一応これも負荷分散）</li>
<li>提供するコンテンツごとにホストを分割</li>
<li>だがスケールするほど構成が複雑になるという難点</li>
</ul>
<h4><a name="l6"> </a>負荷分散クラスタ</h4>
<ul>
<li>いわゆるロードバランサを利用した負荷分散</li>
<li>複数台のホストが同一機能を提供</li>
<li>落ちたホストにはアクセスの振り分けが行われない</li>

<li>スケールしやすい</li>
</ul>
<p>非常に大規模になるとこれらのアプローチを併用することになると思う。</p>
<p>とりあえず今回は主に負荷分散クラスタの話で。</p>
<h3><a name="l7"><span class="sanchor"> </span></a>mod_proxy_balancerって？</h3>
<p>L7での負荷分散を行うApacheのモジュール。
Apache 2.2から使えるようになった。</p>
<p>これによって負荷分散クラスタを構築できる。</p>
<p>今回やっていくのはこれ。</p>
<h3><a name="l8"><span class="sanchor"> </span></a>LVSって？</h3>

<p>Linux Virtual Serverの略。
L4での負荷分散を行うLinuxカーネルの機能。</p>
<p>L7での負荷分散より多くのトラフィックをさばけるが、運用していくにはそれなりのネットワーク知識と英語力（英語の情報が圧倒的に多いので）が必要。
詳しくはWEB+DBプレスのvol.37をあたりをがっつり読んでください。</p>
<p>その他参考。</p>
<ul>
<li><a href="http://dsas.blog.klab.org/archives/50664843.html" class="external">こんなに簡単！ Linuxでロードバランサ (1) - DSAS開発者の部屋</a></li>
<li><a href="http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/" class="external">LVS-HOWTO</a></li>
</ul>
    </div>
  </div>
</div>

<div class="day">
  <h2><span class="date"><a name="l9"> </a></span><span class="title">設定ファイルの書き方</span></h2>
  <div class="body">
    <div class="section">
      <h3><a name="l10"><span class="sanchor"> </span></a>設定の前提</h3>
<ul>
<li>LB機1台 (192.168.1.100)</li>
<li>バックエンド2台 (192.168.1.101, 192.168.1.102)</li>

</ul>
<h3><a name="l11"><span class="sanchor"> </span></a>LB機</h3>
<p>バーチャルホストを作ってそこに設定を書いていく。
（バーチャルホストを定義しなくてもいいが、今回はバーチャルホストにする）</p>
<pre><code>
&lt;VirtualHost *:80&gt;
  ProxyRequest Off
  ProxyPass / balancer://cluster/

  ProxyPass /balancer-manager !

  &lt;Location /balancer-manager&gt;
    SetHandler balancer-manager
    Order Deny,Allow
    Deny from all
    Allow from 192.168.1.0/24
  &lt;/Location&gt;

  &lt;Proxy balancer://cluster/&gt;
    BalancerMember http://192.168.1.101/ loadfactor=10
    BalancerMember http://192.168.1.102/ loadfactor=10
  &lt;/Proxy&gt;
&lt;/VirtualHost&gt;
</code></pre>
    </div>
  </div>
</div>
<div class="day">

  <h2><span class="date"><a name="l12"> </a></span><span class="title">実践編 - 基本 -</span></h2>
  <div class="body">
    <div class="section">
      <h3><a name="l13"><span class="sanchor"> </span></a>二台への負荷分散の確認</h3>
<p>振り分け先のホストにそれぞれ異なる内容のファイル用意してアクセスしてみる。</p>
<p>アクセスの都度異なるホストにつながることを確認する。</p>
<h3><a name="l14"><span class="sanchor"> </span></a>バックエンド一台落ちた</h3>

<p>落ちた方にはアクセスが振り分けられない。</p>
<p>イエス！</p>
<h3><a name="l15"><span class="sanchor"> </span></a>バックエンド全部落ちた</h3>
<p>Service Temporarily Unavailable</p>
<p>そんな時<a href="http://blog.fkoji.com/2007/03261000.html" class="external">猫メソッド</a>。</p>
<pre><code>
ErrorDocument 503 (猫のURL）
</code></pre>
<h3><a name="l16"><span class="sanchor"> </span></a>ロードバランサ落ちた</h3>

<p>冗長化しときましょう。</p>
<h3><a name="l17"><span class="sanchor"> </span></a>バランサマネージャ</h3>
<p>クラスタの状態の確認と更新ができる。</p>
<p>いろいろいじってみましょう。</p>
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l18"> </a></span><span class="title">実践編 - 応用 -</span></h2>

  <div class="body">
    <div class="section">
      <h3><a name="l19"><span class="sanchor"> </span></a>stickysession</h3>
<p>以下の行更新。</p>
<pre><code>
  ProxyPass / balancer://cluster/ stickysession=backendid
</code></pre>
<pre><code>
    BalancerMember http://192.168.1.101/ loadfactor=10 route=1
    BalancerMember http://192.168.1.102/ loadfactor=10 route=2
</code></pre>
<p>次のようなファイルをそれぞれのサーバに置く。</p>
<p>101</p>

<pre><code>
&lt;?php
  setcookie('backendid', "hogehoge.1");
?&gt;
</code></pre>
<p>102</p>
<pre><code>
&lt;?php
  setcookie('backendid', "hogehoge.2");
?&gt;
</code></pre>
<p>「hogehoge.n」が「route=n」に対応する。</p>
<h4><a name="l20"> </a>stickysession張った状態で101が落ちたら</h4>
<p>ギャース！猫再び。</p>
<p>落ちているほうにアクセス振り分けが固定されたままになってしまう。</p>

<h4><a name="l21"> </a>落ちても平気なように</h4>
<p>redirectを指定する。</p>
<pre><code>
    BalancerMember http://192.168.1.101/ loadfactor=10 route=1 redirect=2
    BalancerMember http://192.168.1.102/ loadfactor=10 route=2
</code></pre>
<p>101が落ちていると102の方へつながる。</p>
<p>しかし相互リダイレクトはうまくいかないので、以下のようには書けない。</p>
<pre><code>
    BalancerMember http://192.168.1.102/ loadfactor=10 route=2 redirect=1
</code></pre>
<p>だから102の方が落ちたらやっぱり猫。</p>

<p>バランサマネージャの設定更新がGETで手軽に叩けるようなので、バックエンドをNagiosなどで監視して、落ちていたらリダイレクト先を動的に設定するようなスクリプトを書いたりしておくといいかもしれない。</p>
<p>真面目にやろうとすると意外とめんどいね。stickysession。</p>
<h3><a name="l22"><span class="sanchor"> </span></a>静的ファイルをロードバランサで返す</h3>
<p>バックエンドが動的ファイルを扱うサーバの場合、そのサーバに静的ファイルを扱わせるとリソースがもったいない。
なので静的なファイルはロードバランサが返すようにするとお得。</p>
<p>以下の行追加。</p>
<pre><code>
   ProxyPass /img !
   ProxyPass /css !
</code></pre>
<p>静的ファイルは動的ファイルに比べて負荷が数十分の一から百分の一以下なので、全部ロードバランサでさばいてもけっこういける。</p>

<h3><a name="l23"><span class="sanchor"> </span></a>バックエンドのログのリモートIP</h3>
<p>サーバ変数のREMOTE_ADDRがロードバランサのIPになってしまうので次のような困ったことが起きる。</p>
<ul>
<li>プログラム内でクライアントのリモートIPが取れない（他の変数に記録されるので取ろうと思えば取れるが、プログラムの改変が必要になる）</li>
<li>IPによるアクセス制限が効かなくなる</li>
<li>ログのリモートIPがすべてロードバランサのものになる</li>
</ul>
<p>そこでmod_rpafを使う。</p>
<p>参考 : <a href="http://www.drk7.jp/MT/archives/000573.html" class="external">リバースプロキシを導入する際はmod_rpaf :: Drk7jp</a></p>

<p>バックエンド側で以下の設定を追記。</p>
<pre><code>
   &lt;IfModule mod_rpaf-2.0.c&gt;
       RPAFenable On
       RPAFsethostname Off
       RPAFproxy_ips 192.168.1.100
   &lt;/IfModule&gt;
</code></pre>
    </div>
  </div>
</div>