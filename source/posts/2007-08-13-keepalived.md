---
title: keepalived講習会
date: 2007-08-13 16:34 JST
authors: akahige
tags: infrastructure, resume, 
---
## ゴール
- VRRPによる仮想IP持ち回りの仕組みを理解する
- keepalivedを利用したHAクラスタが構築できる

LVS周りはナシで。

<!--more-->  

## 基礎知識編

### 基本的な資料
- [keepalived 本家](http://www.keepalived.org/)
- [こんなに簡単！ Linuxでロードバランサ (2) - DSAS開発者の部屋](http://dsas.blog.klab.org/archives/50665382.html)

あとは昔まとめた社外秘の資料

### keepalivedって何スか

LinuxにおけるVRRPの実装のひとつ。HAクラスタを実現するデーモン。  

HAクラスタのマスタ機とバックアップ機の両方で動作させることで簡単にHAクラスタができる。

またLVSを利用した負荷分散クラスタの稼動をサポートする機能もある。

### VRRP

仮想IPを複数機器で共有し、一番プライオリティの高い機器がそのIPを持つ仕組み。

本来はルータ冗長化のためのプロトコルだが、サーバの冗長化にも使用できる。  
つまりHAクラスタが作成可能。

参考 : [Virtual Router Redundancy Protocol - Wikipedia](http://ja.wikipedia.org/wiki/Virtual_Router_Redundancy_Protocol)

## 設定ファイルの書き方

設定ファイルは/etc/keepalived/keepalived.conf。

### 設定の前提
- クラスタの仮想IPは192.168.1.10
- MASTERの実IPは192.168.1.11
- BACKUPの実IPは192.168.1.12
- あとでたくさんの仮想IPを持たせる

### MASTER側

MASTERである192.168.1.11のサーバには以下の内容のファイルを置く。

```
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

```

### BACKUP側

BACKUPである192.168.1.12のサーバには以下の内容のファイルを置く。

```
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
```

### 設定値の意味

以下少しだけ説明とか設定上の注意点とか。

#### global\_defs

keepalivedの動作全般に関係し、クラスタ内のサーバに異常が生じた際にメールを飛ばす設定などを行うセクション。

#### vrrp\_instance

仮想ルータを定義するセクション。  
仮想ルータはいくつでも定義でき、またひとつの仮想ルータが複数の仮想IPを持つことが出来る。

#### advert\_int

死活確認のインターバル。

#### virtual\_router\_id

属してる仮想ルータの識別ID。

同一ネットワーク内にvrrpで動作している仮想ルータがある場合、virtual\_router\_idは他の仮想ルータとかぶらない値である必要がある。

#### state, priority

MASTERのpriorityにはBACKUPのpriorityの値より大きなものを設定する。

## 実践編 - 基本 -

### 設定ファイルを編集して仮想IPを増やしたり減らしたりしてみよう
- 設定ファイルの編集

```
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
```

### フェイルオーバー - マスタからバックアップへの切り替え
- 片方ケーブルを抜く
- 両機のIPを確認する

```
$ /sbin/ip address list
```

### フェイルバック - バックアップからマスタへの切り替え
- 抜いたケーブルを戻す
- 両機のIPを確認する

```
$ /sbin/ip address list
```

### マスタとバックアップの設定を入れ替えて切り替え作業をしてみる
- 設定ファイルの編集
- 最初の状態でマスタが入れ替わっていることを確認する
- フェイルオーバーとフェイルバックを確認する

## 実践編 - 応用 -

### フェイルオーバー時とフェイルバック時にスクリプトを実行する
- 自分がマスタになった場合（主にマスタの起動時やフェイルオーバー時）にhoge.shを実行

```
vrrp_instance VI_1 {
...
   notify_master /etc/keepalived/hoge.sh
...
}
```
- 自分がバックアップになった場合（主にフェイルバック時）にhage.shを実行

```
vrrp_instance VI_1 {
...
   notify_backup /etc/keepalived/hage.sh
...
}
```

### 21個以上の仮想IP
- virtual\_ipaddressに21個以上追加してどうなるか試す

```
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
```
- 21個目以上はvirtual\_ipaddress\_excludedに追加する

```
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
```

## 備考

vrrpはネットワークな死活確認しか行わない。  
なのでサービスの死活確認を行いたい場合は別途なんらかの仕組みが必要。

これに関してはクラスタ上の各サーバが自己のサービス監視を行って、サービスがダウンしたらkeepalivedを停止させる、といった事を行えば、サービスが停止したサーバをクラスタから切り離すことができる。

