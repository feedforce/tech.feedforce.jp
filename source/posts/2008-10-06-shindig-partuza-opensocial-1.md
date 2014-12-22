---
title: ShindigとPartuzaでOpenSocialガジェットのテスト環境を構築(その1)
date: 2008-10-06 10:59 JST
authors: fukunaga
tags: resume, 
---
[OpenSocial](http://code.google.com/apis/opensocial/)対応のガジェットを構築するうえでの悩みどころは、「テスト環境どうするの？」というところではないでしょうか。

まだ公開していないガジェットアプリケーションを [Orkut](http://www.orkut.com/)のsandboxでテストするのはちょっとなぁ・・・と思ったことがある人は、ここで紹介するShindigとPartuzaを使ってみるといいかもしれません。

今回はまず Shindig について説明します。

<!--more-->  

## Shindig

[Shindig](http://incubator.apache.org/shindig/)は [OpenSocial API Specification](http://code.google.com/apis/opensocial/docs/0.8/spec.html)と [Gadgets Specification](http://code.google.com/apis/gadgets/docs/spec.html)を実装したオープンソースのプロジェクトです。 [Apache incubator](http://incubator.apache.org/)にて開発が進められています。

Shindigを使うと誰でも自由にOpenSocialガジェットをホストするサイトを構築することができます。ローカル環境に立てればテスト環境が作れるというわけです。

※ iGoogleのガジェットをいくつか試してみましたが、すべてのガジェットが実行できるわけではありませんでした。iGoogle独自のメソッドの多くは実装されていないようです。

### Shindigの構成要素
- Gadget Container JavaScript
- Gadget Server
- OpenSocial Container JavaScript
- OpenSocial Data Server

### 導入

[http://incubator.apache.org/shindig/#php](http://incubator.apache.org/shindig/#php)

Java版もありますが、ここではPHP版で。

#### 必要環境
- Subversion
- mod\_rewrite
- PHP 5.2.x (json, simplexml, mcrypt, curl)

#### ソースをチェックアウト

```
$ mkdir /var/www/shindig
$ cd /var/www/shindig
$ svn co http://svn.apache.org/repos/asf/incubator/shindig/trunk/ .
```

#### バーチャルホストを立てる

ここでは dev.shindig.jp というドメインとします。

```
<VirtualHost 192.168.1.142:80>
    DocumentRoot /var/www/shindig/php
    DirectoryIndex index.html index.php
    ServerName dev.shindig.jp
    AddDefaultCharset UTF-8 

 <Directory /var/www/shindig/php>
        AllowOverride All
    </Directory> 
</VirtualHost>
```

#### PECL json インストール

個人の環境にPECL jsonが入っていなかったのでインストールしました。

```
$ sudo pecl install json
```

### ガジェットを実行してみる

ここまでできれば、すぐにガジェットを実行することができます。エンドポイントは、

```
http://dev.shindig.jp/gadgets/ifr?
```

です。urlパラメータを与えてガジェットを実行します。

```
http://dev.shindig.jp/gadgets/ifr?url=[ガジェットのXMLファイルのURL]
```

![shindig-example.gif](/images/2008/09/shindig-example.gif)

↑ ドキュメントに [サンプルとして記載されているガジェット](http://www.labpixies.com/campaigns/todo/todo.xml)を実行したところ。

このように、Shindigを使うと簡単にOpenSocial対応ガジェットをホスティングする環境を作ることができます。

というわけで、次回はPartuzaについて。

