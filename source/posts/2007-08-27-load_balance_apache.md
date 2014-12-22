---
title: 負荷分散講習会 Apache編
date: 2007-08-27 14:23 JST
authors: akahige
tags: infrastructure, resume, 
---
## ゴール
- 負荷分散のいくつかの方法に関して理解する
- mod\_proxy\_balancerによる負荷分散クラスタが構築できる

<!--more-->  

## 基礎知識編

### 基本的な資料

主にクラスタによる負荷分散の資料。
- [Apache モジュール mod\_proxy\_balancer](http://httpd.apache.org/docs/2.2/ja/mod/mod_proxy_balancer.html)
- [mod\_proxy\_balancerで中?大規模サーバー運用するときの勘所 - cyano](http://www.onflow.jp/blog/archives/2006/02/mod_proxy_balan.html)

あと社外秘資料。

### 負荷分散？

複数台のサーバにアクセスを分散して、個々のサーバにかかる負荷を減らし、全体的に処理できるアクセスを増やすこと。

以下のようなアプローチがある。

#### DNSラウンドロビン
- DNSでひとつのホスト名に複数のIPアドレスを割り当てる方法
- シンプル
- しかしダウンしているホストにもアクセスが振り分けされてしまう

  - 冗長化と併用でなんとかなるかな？

#### 機能ごとにホストを分割
- ウェブサーバとDBサーバの分割（基本過ぎるが一応これも負荷分散）
- 提供するコンテンツごとにホストを分割
- だがスケールするほど構成が複雑になるという難点

#### 負荷分散クラスタ
- いわゆるロードバランサを利用した負荷分散
- 複数台のホストが同一機能を提供
- 落ちたホストにはアクセスの振り分けが行われない
- スケールしやすい

非常に大規模になるとこれらのアプローチを併用することになると思う。

とりあえず今回は主に負荷分散クラスタの話で。

### mod\_proxy\_balancerって？

L7での負荷分散を行うApacheのモジュール。 Apache 2.2から使えるようになった。

これによって負荷分散クラスタを構築できる。

今回やっていくのはこれ。

### LVSって？

Linux Virtual Serverの略。 L4での負荷分散を行うLinuxカーネルの機能。

L7での負荷分散より多くのトラフィックをさばけるが、運用していくにはそれなりのネットワーク知識と英語力（英語の情報が圧倒的に多いので）が必要。 詳しくはWEB+DBプレスのvol.37をあたりをがっつり読んでください。

その他参考。
- [こんなに簡単！ Linuxでロードバランサ (1) - DSAS開発者の部屋](http://dsas.blog.klab.org/archives/50664843.html)
- [LVS-HOWTO](http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/)

## 設定ファイルの書き方

### 設定の前提
- LB機1台 (192.168.1.100)
- バックエンド2台 (192.168.1.101, 192.168.1.102)

### LB機

バーチャルホストを作ってそこに設定を書いていく。 （バーチャルホストを定義しなくてもいいが、今回はバーチャルホストにする）

```
<VirtualHost *:80>
  ProxyRequest Off
  ProxyPass / balancer://cluster/

 ProxyPass /balancer-manager !

 <Location /balancer-manager>
    SetHandler balancer-manager
    Order Deny,Allow
    Deny from all
    Allow from 192.168.1.0/24
  </Location>

 <Proxy balancer://cluster/>
    BalancerMember http://192.168.1.101/ loadfactor=10
    BalancerMember http://192.168.1.102/ loadfactor=10
  </Proxy>
</VirtualHost>
```

## 実践編 - 基本 -

### 二台への負荷分散の確認

振り分け先のホストにそれぞれ異なる内容のファイル用意してアクセスしてみる。

アクセスの都度異なるホストにつながることを確認する。

### バックエンド一台落ちた

落ちた方にはアクセスが振り分けられない。

イエス！

### バックエンド全部落ちた

Service Temporarily Unavailable

そんな時 [猫メソッド](http://blog.fkoji.com/2007/03261000.html)。

```
ErrorDocument 503 (猫のURL）
```

### ロードバランサ落ちた

冗長化しときましょう。

### バランサマネージャ

クラスタの状態の確認と更新ができる。

いろいろいじってみましょう。

## 実践編 - 応用 -

### stickysession

以下の行更新。

```
ProxyPass / balancer://cluster/ stickysession=backendid
```

```
BalancerMember http://192.168.1.101/ loadfactor=10 route=1
    BalancerMember http://192.168.1.102/ loadfactor=10 route=2
```

次のようなファイルをそれぞれのサーバに置く。

101

```
<?php
  setcookie('backendid', "hogehoge.1");
?>
```

102

```
<?php
  setcookie('backendid', "hogehoge.2");
?>
```

「hogehoge.n」が「route=n」に対応する。

#### stickysession張った状態で101が落ちたら

ギャース！猫再び。

落ちているほうにアクセス振り分けが固定されたままになってしまう。

#### 落ちても平気なように

redirectを指定する。

```
BalancerMember http://192.168.1.101/ loadfactor=10 route=1 redirect=2
    BalancerMember http://192.168.1.102/ loadfactor=10 route=2
```

101が落ちていると102の方へつながる。

しかし相互リダイレクトはうまくいかないので、以下のようには書けない。

```
BalancerMember http://192.168.1.102/ loadfactor=10 route=2 redirect=1
```

だから102の方が落ちたらやっぱり猫。

バランサマネージャの設定更新がGETで手軽に叩けるようなので、バックエンドをNagiosなどで監視して、落ちていたらリダイレクト先を動的に設定するようなスクリプトを書いたりしておくといいかもしれない。

真面目にやろうとすると意外とめんどいね。stickysession。

### 静的ファイルをロードバランサで返す

バックエンドが動的ファイルを扱うサーバの場合、そのサーバに静的ファイルを扱わせるとリソースがもったいない。 なので静的なファイルはロードバランサが返すようにするとお得。

以下の行追加。

```
ProxyPass /img !
   ProxyPass /css !
```

静的ファイルは動的ファイルに比べて負荷が数十分の一から百分の一以下なので、全部ロードバランサでさばいてもけっこういける。

### バックエンドのログのリモートIP

サーバ変数のREMOTE\_ADDRがロードバランサのIPになってしまうので次のような困ったことが起きる。
- プログラム内でクライアントのリモートIPが取れない（他の変数に記録されるので取ろうと思えば取れるが、プログラムの改変が必要になる）
- IPによるアクセス制限が効かなくなる
- ログのリモートIPがすべてロードバランサのものになる

そこでmod\_rpafを使う。

参考 : [リバースプロキシを導入する際はmod\_rpaf :: Drk7jp](http://www.drk7.jp/MT/archives/000573.html)

バックエンド側で以下の設定を追記。

```
<IfModule mod_rpaf-2.0.c>
       RPAFenable On
       RPAFsethostname Off
       RPAFproxy_ips 192.168.1.100
   </IfModule>
```

