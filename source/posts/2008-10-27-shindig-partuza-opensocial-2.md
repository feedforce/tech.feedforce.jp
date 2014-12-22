---
title: ShindigとPartuzaでOpenSocialガジェットのテスト環境を構築(その2)
date: 2008-10-27 11:07 JST
authors: fukunaga
tags: resume, 
---
前回はOpenSocialガジェットのホスティング環境を構築できる [Shindig](http://incubator.apache.org/shindig/) について説明しました。

» [FFTT : ShindigとPartuzaでOpenSocialガジェットのテスト環境を構築(その1)](http://tech.feedforce.jp/shindig-partuza-opensocial-1.html)

今回は、その Shindig を利用して OpenSocial 機能を実装している [Partuza](http://www.partuza.nl/) を紹介します。  

<!--more-->

## Partuza

 [Partuza](http://www.partuza.nl/) はオープンソースのSNSです。PHPで書かれています。読み方はよくわかりません。ソースをダウンロードして個人の環境に設置することで使えるようになります。ライセンスは Apache License 2.0 です。  

### こんなとき参考になります

- Apache Shindigを利用してOpen Social対応SNSを作りたい
- すでにあるSNSにApache Shindigを利用したOpen Social機能を実装したい

というわけで、早速 Partuza をインストールしてみます。ソースコードは [partuza - Google Code](http://code.google.com/p/partuza/) から入手できます。  

### Partuza のインストール

#### checkout

```
$ mkdir /var/www/partuza
$ cd /var/www/partuza
$ svn co http://partuza.googlecode.com/svn/trunk .
```

#### バーチャルホストを設定

```
<VirtualHost 192.168.1.142:80>
    DocumentRoot /var/www/partuza/html
    ServerName dev.partuza.jp
    ErrorLog /var/log/httpd/partuza_error_log
    CustomLog /var/log/httpd/partuza_access_log combined

 AddDefaultCharset UTF-8

 <Directory /var/www/partuza/html>
        AllowOverride All
    </Directory>
</VirtualHost>
```

#### 必要であれば
/etc/php.ini に以下の記述があるか。  

```
short_open_tag = On
```

 [gd](http://www.libgd.org/Main_Page)をインストールしていなければインストール。  

#### パーミッション変更

```
$ chmod 777 /var/www/partuza/images/people
```

#### SQL実行(MySQL)

```
$ cd /var/www/partuza
$ mysqladmin -u root -p create partuza
$ mysql -u root -p -D partuza < partuza.sql
```
ここまで設定すれば、Partuza が動きます。

しかし、まだ Shindig が組み込まれていませんので、Shindig を Partuza に組み込む設定をします。  

#### Shindig に local.php を作成

```
$ vi /var/www/shindig/config/local.php
```
local.phpファイルの中身は次のようにする。  

```
<?php

$shindigConfig = array(
                       'people_service' => 'PartuzaPeopleService',
                       'activity_service' => 'PartuzaActivitiesService',
                       'app_data_service' => 'PartuzaAppDataService',
                       'extension_class_paths' => '/var/www/partuza/Shindig',);
```

#### Partuza の config.php を編集
Shindig が動く環境のホスト名を設定します。  

```
$ vi /var/www/partuza/html/config.php
```

```
- 'gadget_server' => 'http://shindig',
+ 'gadget_server' => 'http://dev.shindig.jp',
```
ここまで設定できれば、PartuzaでOpenSocialガジェットが動くようになります。

 ![Partuza](/images/2008/10/partuza-home.gif)

↑ テストで [このガジェット](http://www.google.co.jp/ig/directory?hl=ja&url=map.fkoji.com/kusayakyu/search.xml)を追加してみました。(※ このガジェットにOpenSocialの機能はありません。)  

## まとめ
このように、 Shindig と Partuza を利用すると、OpenSocial対応のガジェットおよびSNSの開発環境を簡単に構築することができます。興味のある方はぜひ利用してみてください。

» [FFTT : ShindigとPartuzaでOpenSocialガジェットのテスト環境を構築(その1)](http://tech.feedforce.jp/shindig-partuza-opensocial-1.html)
