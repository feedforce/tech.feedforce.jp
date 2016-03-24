---
title: mhaとconsulでDBサーバーの冗長化をしています
date: 2016-03-24 14:06 JST
authors: kunishima
tags: operation
---

こんにちは。Lorentzcaです。3月ですがまだまだ寒いのでなかなか釣りに行けずテンションさげぽよです！ ↑↑

この度DBサーバー(物理マシン、MySQL)の引っ越しを行いました。  
そのついでに、冗長化の仕組みをmhaとconsulを使った方法に変えたので紹介します。

<!--more-->

## はじめに

まずは簡単に引っ越し前と引っ越し後の構成を比べてみます。

引っ越し前は以下の様な構成でした。

- サーバー台数: 2台
- MySQLフェイルオーバーの仕組み: 自作シェルスクリプト
- アプリの参照先を切り替える仕組み: keepalivedでvipを張り替えることで実現

引っ越し後は以下の様な構成になりました。

- サーバー台数: <font color=red>3台</font>
- MySQLフェイルオーバーの仕組み: <font color=red>mha</font>
- アプリの参照先を切り替える仕組み:<font color=red>consulのdns機能を使って実現</font>

なぜ、どのようにしてmhaとconsulを使った冗長化を行ったか、なんで1台増えてるのかを話していきます。

## 引っ越し前に持っていた問題意識

以下の様な課題があり、これを解決するために今までとは違う冗長化の仕組みを導入することにしました。

- サーバー2台だとOSやミドルウェアのアップデートが気軽にできない
	- アップデート作業中、冗長化構成ではなくなるので不安な気持ちになる
- 自作シェルスクリプトとkeepalivedによる冗長化構成はメンテし辛い
	- 自作シェルスクリプトが秘伝のタレ化している
	- keepalivedは起動順やpriorityの設定に気をつけないとvipが期待するサーバーにセットされないのでつらい
- マスタで障害発生した場合、復旧が大変
	- 元マスタを復旧しスレーブとして追加する際に、現マスタからMySQLのスナップショットを取る都合上ダウンタイム必須

## どのように解決したか！

### サーバーを3台にする

以下の様な理由で3台にしました。

- サーバーが1台壊れたとしても、スレーブを一時的に止めてスナップショットを取ることができるので、復旧時のダウンタイムをなくせる
- メンテナンスなどでサーバーを再起動するときに、残りの2台で冗長性を確保できる

### 自作スクリプトをやめてmhaを使う

[mha](https://code.google.com/p/mysql-master-ha/)とは複雑な操作や苦しみを伴うこと無く、マスタのフェイルオーバーを行えるツールです。  
マスタのダウン等による自動的なフェイルオーバーだけでなく、オンラインでのマスタサーバーの切り替えも行えます。(サーバーのメンテナンスをしたい時に便利)

以下の様な理由で導入しました。

- 自作シェルスクリプトからの脱却
- 導入実績が多い
- 障害からの復旧が簡単になる

### keepalivedをやめてconsulを使う

[consul](https://www.consul.io/)とはサービス(nginx等)の検出や動的な設定を行うための仕組みを提供するツールです。  
といってもイメージしにくいと思いますし、実際色々なことが出来ます。具体的には…、おや、こんなところに事例が！

- [stretcher + consul + capistrano を使ったデプロイを導入しようと思います | feedforce Engineers' blog](http://tech.feedforce.jp/stretcher-consul-capistrano.html)

さて、consulにはdns機能が内蔵されており、今回はこのdns機能とmhaを連携させることで **「マスタDBサーバーはどこか」** をconsulに問い合わせればわかるようにしました。

以下の様な理由で導入しました。

- 導入が簡単
- [事例](http://ijin.github.io/blog/2014/07/11/mysql-failover-with-consul/)がある
- apiで操作できる(mha等のツールと連携させやすい)
- 3台以上のサーバーで使える
	- これに関してはkeepalivedでも出来なくはないが、秘伝のタレが加速しそうだった
- **好き好きhashicorp**

consulの使い方としてはちょっと変則的な気がしますが、今後別の用途でも活用できそうなので良し！ です。

## mhaとconsulの連携方法

mhaやconsulの設定や基本的な使い方はドキュメントに詳しく書いてあるのでそちらを見ていただければと思います。

今回どのようにmhaとconsulを連携させているかがキモとなるので、その部分に絞って紹介します。

### master\_ip\_failover\_script

mhaはフェイルオーバー時に任意のスクリプトを実行することが出来ます。  
スクリプトの指定は`/etc/mha.cnf`内に以下のように追記することで指定できます。

```
master_ip_failover_script=/path/to/script_name
```

実際にDBマスタサーバーがダウンしてフェイルオーバーが行われる際、以下のようにしてこのスクリプトが実行されます。これはmhaのログで確認できます。(見やすさのため改行しています)

```
/path/to/script_name --command=start \
--ssh_user=sshuser \
--orig_master_host=10.0.0.100 \
--orig_master_ip=10.0.0.100 \
--orig_master_port=3306 \
--new_master_host=10.0.0.101 \
--new_master_ip=10.0.0.101 \
--new_master_port=3306 \
--new_master_user='masteruser' \
--new_master_password='password' \
--ssh_options='\
-o ServerAliveInterval=60 \
-o ServerAliveCountMax=20 \
-o StrictHostKeyChecking=no \
-o ConnectionAttempts=5 \
-o PasswordAuthentication=no \
-o BatchMode=yes \
-i /path/to/ssh/privkey'
```


何か色々な引数を渡して実行されているのがわかります。

スクリプトを一から作るのは大変なので、[サンプル](https://github.com/yoshinorim/mha4mysql-manager/blob/master/samples/scripts/master_ip_failover)を利用します。

サンプルにある`FIXME_xxx;`を以下のように書き換えることで、consul(10.0.0.50)のapiを叩き、新マスタサーバーがどのホストなのかを知らせています。ここでmhaがスクリプトに渡していた引数(`new_master_ip`)が役に立ちます。

```
  ## Update master ip on the catalog database, etc
- FIXME_xxx;
+ system("curl -s -X PUT -d \'{ \"Node\": \"master\", \"Address\": \"$new_master_ip\" }\' http://10.0.0.50:8500/v1/catalog/register");
```

もう一箇所、DBのユーザーを新しく作成するためのコードを書くFIXMEがありますが、今回はあらかじめ各DBサーバーにユーザーを作っていたので、コメントアウトしました。

```
  ## Creating an app user on the new master
- print "Creating app user on the new master..\n";
- FIXME_xxx_create_user( $new_master_handler->{DBh} );
- $new_master_handler->enable_log_bin_local();
- $new_master_handler->disconnect();
+ #print "Creating app user on the new master..\n";
+ #FIXME_xxx_create_user( $new_master_handler->{DBh} );
+ #$new_master_handler->enable_log_bin_local();
+ #$new_master_handler->disconnect();
```

## アプリはどのようにconsulのdnsを利用するか

さて、consulのカタログデータベースにDBマスタサーバーのノードを登録すると、以下のように名前を引けるようになります。

```
$ dig @10.0.0.50 -p 8600 master.node.consul +short
10.0.0.100
```

しかし、名前を引くのにいちいちポートやネームサーバーの指定をしたくないので、 
`*.consul`という名前の場合はdnsmasqを使ってconsulのDNSへ名前解決しにいくよう設定しました。

### *.consulの名前の問い合わせ先を指定する設定

`*.consul`の名前を引くときは10.0.0.50の8600ポートに問い合わせる設定をします。

```
$ cat /etc/dnsmasq.d/consul.conf
server=/consul/10.0.0.50#8600
```

### resolv.confに書かれた順に名前解決を試すための設定

`/etc/dnsmasq.conf`にある`#strict-order`のコメントを外し有効にしておきます。

### dnsmasqをリゾルバに追加する

```
$ cat /etc/resolv.conf
nameserver 127.0.0.1
nameserver 8.8.8.8
```

以下の様な動作をするようになります。

- 名前を引く → dnsmasq(127.0.0.1)へ聞きに行く → `*.consul`ならconsul(10.0.0.50)へ、それ以外なら8.8.8.8へ問い合わせる

これでポートやネームサーバーの指定をしないで`*.consul`の名前を引けるようになりました。

```
$ dig master.node.consul +short
10.0.0.100
```

## 所感

障害が起きてもより落ち着いて対応できるようになったのと、復旧の手順が簡単になり、ダウンタイムをとらなくてもよくなったのが非常に喜ばしいです。

冒頭でさらっとサーバーの引っ越しをしましたと書いていますがかなり大変でした。大変でしたが、既存の仕組みをより保守しやすい仕組みに変えられたのでやる価値はありました！  
大きな変更を加えるにはこのタイミングしか無い、とチャンスを逃さなくてよかったです。

今後はconsulをDBマスタサーバーへの名前引き以外でも活用していくぞ！

## 参考リンク

- [Consul by HashiCorp](https://www.consul.io/)
- [mysql-master-ha](https://code.google.com/p/mysql-master-ha/)
- [ConsulによるMySQLフェールオーバー - @ijin](http://ijin.github.io/blog/2014/07/11/mysql-failover-with-consul/)
- [mha4mysql-manager/samples/scripts at master · yoshinorim/mha4mysql-manager · GitHub](https://github.com/yoshinorim/mha4mysql-manager/tree/master/samples/scripts)
- [Consul, DNS and Dnsmasq](http://www.morethanseven.net/2014/04/25/consul/)
