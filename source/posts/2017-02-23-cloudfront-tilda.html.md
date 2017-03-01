---
title: CloudFront + Tilda でソーシャルPLUSのプロモーションサイトを一新しました
date: 2017-02-23 19:04 JST
authors: mizukmb
tags: infrastructure, operation
---

はじめまして。新卒エンジニアの [mizukmb](https://twitter.com/mizukmb) です。普段はソーシャルPLUSチームでインフラ担当としてアレコレしてます。

先日、ソーシャルPLUSのプロモーションサイトを一新しました。  🎊 [https://socialplus.jp](https://socialplus.jp)
それに伴いインフラ構成も CloudFront と Tilda で作り直し、いい感じの運用ができるようになりましたので紹介します。

<!--more-->

![socialplusjp](/images/2017/02/promotion.png)
https://socialplus.jp

## 経緯

これまで、プロモーションサイトの修正やコンテンツの追加を行う場合、マーケティングチームからエンジニアに修正の依頼をする必要がありました。これにより、**マーケティング・エンジニアの両方に追加タスクが発生してしまう問題をこれまで抱えていました。**
そこで、コンテンツの修正などの作業がマーケティングチームだけで完結できるように、 [Tilda](https://tilda.cc) と呼ばれる CMS サービスを利用することにしました。 Tilda は、ウェブサイトを直接操作するような UI を持ち、コードをいじらなくてもデザインや文言の調整を行えるのが特徴です。

## 構成

Tilda でカスタムドメインを利用する際、 http しかサポートされず https は利用できないという問題があります。[問い合わせフォーム](https://socialplus.jp/inquiry/)を設置している関係上、 https 化は必須でした。そこで、 AWS が提供する [CloudFront](https://aws.amazon.com/jp/cloudfront/) というCDN サービスを間に挟むことで https のカスタムドメインでもアクセスできるようにしました。[^1]

[^1]: Tilda 公式の[ヘルプページ](https://help.tilda.ws/https)でも、 CDN サービスを利用するように紹介されています。

CloudFront の設定は特殊なことを行っておらず、 Origin Domain Name に Tilda 側の URL をセットして、 default TTL を短めに設定したことくらいです。また、上記理由により http は利用できないため、アクセスは全て https にリダイレクトさせています。

以下全体図

![socialplusjp](/images/2017/02/socialplusjp.png)

CloudFront で ACM を利用する場合はバージニア北部 ( us-east-1 ) で取得しなければならない点は注意が必要です。

## 得られた恩恵

今回の変更によって、 **コンテンツの管理やサイトの改修をマーケティングチームだけで完結するようになりました。**
Tilda 側でコンテンツに何かしらの変更が加えられると、CloudFront が自動でキャッチしていい感じに各エッジノードへデプロイしてくれます。
マーケティングチームはインフラ面を気にすることのない、完全にコンテンツにのみ集中できる環境になりました。

また、**ドメインや SSL 証明書、 CDN 全てを AWS 上で管理できるようにもなりました。** ソーシャルPLUSチームではこれらを [terraform](https://www.terraform.io) を使ってコード化しているので、 GitHub 上で管理ができたりと非常に便利になりました。


## まとめ

CloudFront と Tilda を使ってプロモーションサイトを一新したことと、そこから得られた恩恵について紹介しました。
