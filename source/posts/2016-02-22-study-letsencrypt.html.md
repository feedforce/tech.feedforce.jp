---
title: 入門Let's Encryptという勉強会をしました
date: 2016-02-22 15:00 JST
authors: sugiuchi
tags: resume
---

Let's Encrypt！！インフラ担当の杉内です。

少し前になりますが毎週金曜に行っている社内の勉強会でLet's Encryptについて発表しました。
今日は資料の公開とスライド中ではデモで済ませてしまったところのフォローを交えつつ紹介したいと思います。

<!--more-->

資料はこちら

<script async class="speakerdeck-embed" data-id="f66dffb7f52b4b55b8b5b5b548fe81a2" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>

## Let's Encryptとは

[Let's Encrypt](https://letsencrypt.org/)とはSSL/TLS証明書を無料で発行してくれる認証局です。
SSL証明書を無料で発行するとともに、発行、インストール、更新を自動化しHTTPSの普及を目的としています。

SSL証明書が無料という部分も魅力的ですが、注目すべきは証明書に関連する作業が自動化されるところです。
SSL証明書の取得は支払いやドメインの所持者かどうかの確認等、手作業が必要な部分が多く自動化しづらいのが現状です。そこを自動化していこうというスタンスはとても素晴らしいです！

以下デモパートでの一連の流れです。

## 下準備

今回試した環境はCentOS7 + Apache2.4です。
取得する証明書のドメインは `letsen.critical-alert.net` で、
このドメインのAレコードは証明書をインストールするサーバに向いています。

クライアントの取得にgitが必要なのでインストールします。

```
$ yum install git
```

webサーバはapacheを使うのでインストールし、起動させておきます。

```
$ yum install httpd
$ systemctl start httpd
```

## 証明書の取得

実際に証明書を取得していきます。
下準備の通り、apacheをインストール&起動済みです。

Let's EncryptのクライアントがGitHub上で公開されていますのでそれを使います。

```
$ git clone https://github.com/letsencrypt/letsencrypt
```

次にLet's Encryptクライアントが依存するパッケージをインストールします。
letsencrypt-auto というスクリプトが本体になっていて、このスクリプトを実行します。

```
$ cd letsencrypt
$ ./letsencrypt-auto --help
```

はい。helpを実行しただけですが、スクリプト起動時にいきなりyumでパッケージがザクザクインストールされてびっくりします...
このスクリプトはOSを自動判定してpythonやgcc、openssl-develなどクライアントを動かすのに必要なライブラリなどがインストールされます。
(本番環境への導入時はこの辺のパッケージのインストールやアップデートの影響がないか確認をしたほうが良さそうです)

次に取得のコマンドを実行します。

```
$ ./letsencrypt-auto certonly --text \
-d letsen.critical-alert.net \
--webroot --webroot-path=/var/www/html \
-m sample@example.com \
--agree-tos
```

スライド中のオプションと違っている部分がありますので、1個づつ解説します。
(--rsa-key-size はデフォルトで2048でした)

- certonly
  - 証明書のみを取得します
- -d
  - 取得するドメインを指定します
- --webroot
  - webサーバのドキュメントルートに認証用のファイルを生成します
- --webroot-path
  - ドキュメントルートのパスを指定します
- -m
  - メールアドレスを指定します。アカウントとして使用され緊急の連絡等にも使用されるようです
- --agree-tos
  - 利用規約に同意します

メールアドレスやagree-tosは初回のみ実行すればOKです。

## 証明書の保存場所

コマンドを実行して下記のような出力があれば取得できています。

```
IMPORTANT NOTES:

 - Congratulations! Your certificate and chain have been saved at
   /etc/letsencrypt/live/letsen.critical-alert.net/fullchain.pem. Your
   cert will expire on 2016-05-07. To obtain a new version of the
   certificate in the future, simply run Let's Encrypt again.

以下略
```

無事に取得できているか確認します。
取得した証明書は `/etc/letsencrypt/live` というディレクトリにドメインごとに保存されます。

```
ls /etc/letsencrypt/live/letsen.critical-alert.net/

cert.pem -> ../../archive/letsen.critical-alert.net/cert1.pem
chain.pem -> ../../archive/letsen.critical-alert.net/chain1.pem
fullchain.pem -> ../../archive/letsen.critical-alert.net/fullchain1.pem
privkey.pem -> ../../archive/letsen.critical-alert.net/privkey1.pem
```

このようにシンボリックリンクになっていて、本体は `archive` というディレクトリに保存されています。
更新時はこのシンボリックリンク先が差し代わるようになっていて、webサーバ側の設定を変えなくていいようになっています。

証明書はそれぞれこのようになっています。

```
cert.pem > 証明書
chain.pem > 中間証明書
fullchain.pem > 証明書+中間証明書(Nginxはこれを使用)
privkey.pem > 秘密鍵
```

取得した証明書をapacheに設定します。
cert.pem、chain.pem、privkey.pem の3ファイルを使います。

```
$ vi /etc/httpd/conf.d/ssl.conf

中略
SSLCertificateFile /etc/letsencrypt/live/letsen.critical-alert.net/cert.pem
SSLCertificateKeyFile /etc/letsencrypt/live/letsen.critical-alert.net/privkey.pem
SSLCertificateChainFile /etc/letsencrypt/live/letsen.critical-alert.net/chain.pem
```

設定できたらリロードします。

```
$ systemctl reload httpd
```

ブラウザでアクセスし、証明書を確認するとちゃんと Let's Encrypt で取得した証明書が表示されます！

![Letsencrypt](/images/2016/02/letsencrypt.png)

## おわりに

ざっくりの解説でしたが以上のように非常に簡単に、無料で証明書が取得できます。
ここから実運用に乗せるには更新を仕込んだりする必要があります。-> [更新について](https://letsencrypt.readthedocs.org/en/latest/using.html#renewal)
それから複数台構成や構成管理を行っているサーバに対してはどう管理していったらいいかという課題はあります。
Let's Encrypt側でも更新プロセスの改善を行っていくという一文が上記のマニュアルにも記載されており、今後の展開をチェックしていこうと思っています。

また、つい先日AWSも[AWS Certificate Manager](https://aws.amazon.com/jp/certificate-manager/)というELBとCloudFrontで使用可能な無料証明書サービスがリリースし、こちらも証明書の更新が自動化されているようです。
まだ東京リージョンのELBにdeployすることはできませんがこれによりますます証明書の無料化、自動化が加速しそうな感じがしますね！
