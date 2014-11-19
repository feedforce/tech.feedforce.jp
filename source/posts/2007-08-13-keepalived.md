---
title: keepalived講習会
date: 2007-08-13 16:34:53
authors: akahige
tags: infrastructure, resume, 
---
<div class="day">
  <h2><span class="date"><a name="l0"> </a></span><span class="title">ゴール</span></h2>
  <div class="body">
    <div class="section">
      <ul>
<li>VRRPによる仮想IP持ち回りの仕組みを理解する</li>
<li>keepalivedを利用したHAクラスタが構築できる</li>
</ul>

<p>LVS周りはナシで。</p>
    </div>
  </div>
</div>
<!--more-->
<div class="day">
  <h2><span class="date"><a name="l1"> </a></span><span class="title">基礎知識編</span></h2>
  <div class="body">
    <div class="section">
      <h3><a name="l2"><span class="sanchor"> </span></a>基本的な資料</h3>

<ul>
<li><a href="http://www.keepalived.org/" class="external">keepalived 本家</a></li>
<li><a href="http://dsas.blog.klab.org/archives/50665382.html" class="external">こんなに簡単！ Linuxでロードバランサ (2) - DSAS開発者の部屋</a></li>
</ul>
<p>あとは昔まとめた社外秘の資料</p>
<h3><a name="l3"><span class="sanchor"> </span></a>keepalivedって何スか</h3>
<p>LinuxにおけるVRRPの実装のひとつ。HAクラスタを実現するデーモン。<br>

HAクラスタのマスタ機とバックアップ機の両方で動作させることで簡単にHAクラスタができる。</p>
<p>またLVSを利用した負荷分散クラスタの稼動をサポートする機能もある。</p>
<h3><a name="l4"><span class="sanchor"> </span></a>VRRP</h3>
<p>仮想IPを複数機器で共有し、一番プライオリティの高い機器がそのIPを持つ仕組み。</p>
<p>本来はルータ冗長化のためのプロトコルだが、サーバの冗長化にも使用できる。<br>
つまりHAクラスタが作成可能。</p>
<p>参考 : <a href="http://ja.wikipedia.org/wiki/Virtual_Router_Redundancy_Protocol" class="external">Virtual Router Redundancy Protocol - Wikipedia</a></p>
    </div>

  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l5"> </a></span><span class="title">設定ファイルの書き方</span></h2>
  <div class="body">
    <div class="section">
      <p>設定ファイルは/etc/keepalived/keepalived.conf。</p>
<h3><a name="l6"><span class="sanchor"> </span></a>設定の前提</h3>

<ul>
<li>クラスタの仮想IPは192.168.1.10</li>
<li>MASTERの実IPは192.168.1.11</li>
<li>BACKUPの実IPは192.168.1.12</li>
<li>あとでたくさんの仮想IPを持たせる</li>
</ul>
<h3><a name="l7"><span class="sanchor"> </span></a>MASTER側</h3>
<p>MASTERである192.168.1.11のサーバには以下の内容のファイルを置く。</p>
<pre><code>
# Configuration File for keepalived
global_defs {
	notification_email {
               hogehoge@feedforce.jp
	}
	notification_email_from keepalived@feedforce.jp
	smtp_server localhost
	smtp_connect_timeout 30
}

vrrp_instance VI_1 {
        state MASTER
        interface eth0
        virtual_router_id 51
        priority 150
        advert_int 1
        authentication {
                auth_type PASS
                auth_pass 1111
        }
        virtual_ipaddress {
                192.168.1.10
        }
}

</code></pre>
<h3><a name="l8"><span class="sanchor"> </span></a>BACKUP側</h3>
<p>BACKUPである192.168.1.12のサーバには以下の内容のファイルを置く。</p>
<pre><code>
# Configuration File for keepalived
global_defs {
	notification_email {
               hogehoge@feedforce.jp
	}
	notification_email_from keepalived@feedforce.jp
	smtp_server localhost
	smtp_connect_timeout 30
}

vrrp_instance VI_1 {
        state BACKUP
        interface eth0
        virtual_router_id 51
        priority 100
        advert_int 1
        authentication {
                auth_type PASS
                auth_pass 1111
        }
        virtual_ipaddress {
                192.168.1.10
        }
}
</code></pre>
<h3><a name="l9"><span class="sanchor"> </span></a>設定値の意味</h3>
<p>以下少しだけ説明とか設定上の注意点とか。</p>
<h4><a name="l10"> </a>global_defs</h4>

<p>keepalivedの動作全般に関係し、クラスタ内のサーバに異常が生じた際にメールを飛ばす設定などを行うセクション。</p>
<h4><a name="l11"> </a>vrrp_instance</h4>
<p>仮想ルータを定義するセクション。<br>
仮想ルータはいくつでも定義でき、またひとつの仮想ルータが複数の仮想IPを持つことが出来る。</p>
<h4><a name="l12"> </a>advert_int</h4>
<p>死活確認のインターバル。</p>
<h4><a name="l13"> </a>virtual_router_id</h4>

<p>属してる仮想ルータの識別ID。</p>
<p>同一ネットワーク内にvrrpで動作している仮想ルータがある場合、virtual_router_idは他の仮想ルータとかぶらない値である必要がある。</p>
<h4><a name="l14"> </a>state, priority</h4>
<p>MASTERのpriorityにはBACKUPのpriorityの値より大きなものを設定する。</p>
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l15"> </a></span><span class="title">実践編 - 基本 -</span></h2>

  <div class="body">
    <div class="section">
      <h3><a name="l16"><span class="sanchor"> </span></a>設定ファイルを編集して仮想IPを増やしたり減らしたりしてみよう</h3>
<ul>
<li>設定ファイルの編集</li>
</ul>
<pre><code>
vrrp_instance VI_1 {
...
        virtual_ipaddress {
                192.168.1.10
                192.168.1.101
                192.168.1.102
                192.168.1.103
                192.168.1.104
        }
...
}
</code></pre>
<h3><a name="l17"><span class="sanchor"> </span></a>フェイルオーバー - マスタからバックアップへの切り替え</h3>

<ul>
<li>片方ケーブルを抜く</li>
<li>両機のIPを確認する</li>
</ul>
<pre><code>
$ /sbin/ip address list
</code></pre>
<h3><a name="l18"><span class="sanchor"> </span></a>フェイルバック - バックアップからマスタへの切り替え</h3>
<ul>
<li>抜いたケーブルを戻す</li>
<li>両機のIPを確認する</li>

</ul>
<pre><code>
$ /sbin/ip address list
</code></pre>
<h3><a name="l19"><span class="sanchor"> </span></a>マスタとバックアップの設定を入れ替えて切り替え作業をしてみる</h3>
<ul>
<li>設定ファイルの編集</li>
<li>最初の状態でマスタが入れ替わっていることを確認する</li>
<li>フェイルオーバーとフェイルバックを確認する</li>
</ul>
    </div>

  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l20"> </a></span><span class="title">実践編 - 応用 -</span></h2>
  <div class="body">
    <div class="section">
      <h3><a name="l21"><span class="sanchor"> </span></a>フェイルオーバー時とフェイルバック時にスクリプトを実行する</h3>
<ul>

<li>自分がマスタになった場合（主にマスタの起動時やフェイルオーバー時）にhoge.shを実行</li>
</ul>
<pre><code>
vrrp_instance VI_1 {
...
   notify_master /etc/keepalived/hoge.sh
...
}
</code></pre>
<ul>
<li>自分がバックアップになった場合（主にフェイルバック時）にhage.shを実行</li>
</ul>
<pre><code>
vrrp_instance VI_1 {
...
   notify_backup /etc/keepalived/hage.sh
...
}
</code></pre>
<h3><a name="l22"><span class="sanchor"> </span></a>21個以上の仮想IP</h3>
<ul>

<li>virtual_ipaddressに21個以上追加してどうなるか試す</li>
</ul>
<pre><code>
vrrp_instance VI_1 {
...
        virtual_ipaddress {
                192.168.1.10
                ...(18個略)
                192.168.1.119
                192.168.1.120
                192.168.1.121
                192.168.1.122
        }
...
}
</code></pre>
<ul>
<li>21個目以上はvirtual_ipaddress_excludedに追加する</li>
</ul>
<pre><code>
vrrp_instance VI_1 {
...
        virtual_ipaddress {
                192.168.1.10
                ...(18個略)
                192.168.1.119
        }
        virtual_ipaddress_excluded {
                192.168.1.120
                192.168.1.121
                192.168.1.122
        }
...
}
</code></pre>
    </div>
  </div>

</div>
<div class="day">
  <h2><span class="date"><a name="l23"> </a></span><span class="title">備考</span></h2>
  <div class="body">
    <div class="section">
      <p>vrrpはネットワークな死活確認しか行わない。<br>
なのでサービスの死活確認を行いたい場合は別途なんらかの仕組みが必要。</p>
<p>これに関してはクラスタ上の各サーバが自己のサービス監視を行って、サービスがダウンしたらkeepalivedを停止させる、といった事を行えば、サービスが停止したサーバをクラスタから切り離すことができる。</p>

    </div>
  </div>
</div>