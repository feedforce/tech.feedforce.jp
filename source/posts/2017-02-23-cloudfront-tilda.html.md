---
title: CloudFront + Tilda でソーシャルPLUSのプロモーションサイトを一新しました
date: 2017-02-23 19:04 JST
authors: mizukmb
tags: infrastructure, operation
---

はじめまして。新卒エンジニアの [mizukmb](https://twitter.com/mizukmb) です。普段はソーシャルPLUSチームでインフラ担当としてアレコレしてます。

先日、ソーシャルPLUSのプロモーションサイトを一新しました。 [https://socialplus.jp](https://socialplus.jp)
それに伴いインフラ構成も CloudFront と Tilda で作り直し、いい感じの運用ができるようになりましたので紹介します。

<!--more-->

## Tilda とは

[Tilda] (https://tilda.cc) はウェブサイトを直接操作するような UI が特徴的な CMS サービスです。トップページから、すでにおしゃれな感じが漂っています。

![tilda](/images/2017/02/tilda.png)
https://tilda.cc

ソーシャルPLUSでは主にマーケティングチームが Tilda を利用してプロモーションサイトを作成しています。

## 構成

このまま Tilda だけで運用しても良かったのですが、カスタムドメインを利用する際、 http しかサポートされず https は利用できないという問題がありました。
http しかないウェブサイトはさすがにアレなので、 AWS が提供する [CloudFront](https://aws.amazon.com/jp/cloudfront/) という CDN サービスを間に挟むことで https のカスタムドメインでもアクセスできるようにしました。[^1]

[^1]: Tilda 公式の[ヘルプページ](https://help.tilda.ws/https)でも、 CDN サービスを利用するように紹介されています。

CloudFront の設定は特殊なことを行っておらず、 Origin Domain Name に Tilda 側の URL をセットして、 default TTL を短めに設定したことくらいです。

以下全体図

![socialplusjp](/images/2017/02/socialplusjp.png)

CloudFront で ACM を利用する場合はバージニア北部 ( us-east-1 ) で取得しなければならない点は注意が必要です。

## 得られた恩恵

今回の変更によって、 **コンテンツの管理やサイトの改修をマーケティングチームだけで完結するようになり、インフラチームの作業が一切発生しなくなりました。**
Tilda 側でコンテンツに何かしらの変更が加えられると、CloudFront が自動でキャッチしていい感じに各エッジノードへデプロイしてくれますので、マーケティングチームは完全にコンテンツにのみ集中できる環境になりました。

ドメイン、 SSL 証明書、 CDN までを AWS 上で管理できるようにもなりました。ソーシャルPLUSチームではこれらを terraform を使ってコード化しているので、その辺りの管理が非常に楽になりました。


## まとめ
CloudFront と Tilda を使ってプロモーションサイトを一新したことと、そこから得られた恩恵について紹介しました。
