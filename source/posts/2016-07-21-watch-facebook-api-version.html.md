---
title: Facebook API アップデートと付き合う話
date: 2016-07-21 18:25 JST
authors: e-takano
tags:
---

最近スカイアイランドとテレストレーションというボードゲームを買いました、フィードフォース ボドゲ部の kano-e です。
仕事では Facebook のドキュメントをいっぱい読んでいる今日この頃、Rails エンジニアです。

さて、先日 7/13 (日本時間だと 7/14 ですね) に Facebook API v2.7 がリリースされました。
弊社の ソーシャル PLUS や Feedmatic では Facebook API を利用していますので、さっそく影響範囲の確認や対応リリースが行われました。
(ソーシャル PLUS の対応リリースは 7/14 中でした)

Facebook API は三ヶ月を目安にバージョンアップが行われます。
ですので、Facebook API を利用している場合、定期的にその対応が必要になります。

この記事では、 Facebook API と長くお付き合いするためのアレコレについて、軽くまとめたいと思います。

<!--more-->

## API バージョンの寿命

冒頭でも述べましたが Facebook API の新しいバージョンは三ヶ月を目安にリリースされます。
過去には六ヶ月空くこともありましたが、大体三ヶ月毎に新しいバージョンがくる、と思っておくと慌てなくて済みます。

新しいバージョンがリリースされるタイミングで、古いバージョンが廃止される時期も決定します。
API バージョンがいつ廃止されるか、その寿命は Graph API と Marketing API で違っています。

### Graph API の場合

Graph API の場合、次のバージョンがリリースされてから二年間で、そのバージョンは使えなくなります。
例えば v2.7 が 2016/07/13 にリリースされたので、 v2.6 はそこから2年後の 2018/07/13 が期限です。

この辺りのことは [Platform Versioning](https://developers.facebook.com/docs/apps/versions) のページにまとまっています。

また、 Facebook の App ID と App Secret の発行に必要な Facebook App も、 API Version という属性を持っています。
この API Version という属性に設定されたバージョンより古い API バージョンは、その Facebook App では利用できません。

この API Version は、アプリ作成時の最新の API バージョンが設定されます。
以降、設定されたバージョンが無効になると Facebook がこの項目を自動でアップデートします。

ですので Facebook API を利用する場合には、自分の所有する Facebook App の API Version も合わせて確認しておく必要があります。

### Marketing API の場合

Marketing API の場合、寿命がもう少し短く、次の次のバージョンが出るタイミングで無効になっています。
例えば v2.4 は v2.6 がリリースされた 2016/04/12 の前日 2016/04/11 が期限です。

Marketing API の期限は、次のバージョンがリリースされたタイミングで目安が公開されます。
今であれば v2.7 が公開され、 v2.6 の期限は 2016/10 となっています。
これはつまり 2016/10 に次のバージョンである v2.8 が出る予定、ということになります。

## 変更点を調べる

バージョンの変更点は [Facebook Platform Changelog](https://developers.facebook.com/docs/apps/changelog) にまとまっています。
以前は Marketing API の Changelog は別ページだったのですが、 v2.5 のタイミングで Platform Changelog に統一されました。
個人的な感想を言うと、確認すべき場所が一カ所にまとまったので、確認作業が楽になって助かっています。

詳細については、個別のドキュメントページへのリンクになっていることが多いので、そちらも合わせて確認します。

パラメータやフィールドの名前が変わった、という変更であれば、影響がわかりやすいのですぐに対応できることが多いです。

過去には「エンドポイントが変わった」「オブジェクトの構造が変わった」「エンドポイントや機能自体が廃止になった」ということもありました。
2016/8/4 には完全廃止となりますが、 FQL (Facebook Query Language) という機能もありましたね、そういえば。

そのような影響の大きい変更だと即日対応は難しいですが、その場合は各サービス毎にスケジュールをたてて対応しています。

また、 Facebook には [API Upgrade Tool](https://developers.facebook.com/tools/api_versioning/) というツールが用意されています。
Facebook App の使用履歴から、特定のバージョンで使えないリクエストがあれば、それをリストアップしてくれるツールです。
使い方は[ドキュメント](https://developers.facebook.com/docs/graph-api/advanced/api-upgrade-tool)をご覧ください。
(残念ながら弊社の ソーシャル PLUS では、お客様が Facebook App を作成して管理画面に登録するというサービスですので、このツールですべて解決できないこともあります……)

## バージョンアップに気付きたい

いつの間にか新しいバージョンがリリースされている、というのは嫌ですね。
特に Marketing API は寿命が短いため、できるだけ早く気付きたいものです。

弊社 Slack には、各認証プロバイダの開発者向け更新情報を通知するチャンネルがあります。
ここには Facebook の [Developer News](https://developers.facebook.com/blog/) のフィードも含まれているので、API バージョンのリリースにも気付けます。

また [Developer Settings](https://developers.facebook.com/settings/developer/contact/) から、各項目毎に通知設定ができます。
ここで `Notify By Email` を `Yes` にしておくと、自分の Facebook アカウントのプライマリなメールアドレスに、通知メールが届くようになります。

Marketing API だけですが、ドキュメント更新の際の通知も可能です。

バージョンアップによる影響調査は、それぞれのサービス毎に行われます。
調査内容は Github の issue にコメントされることが多いのですが、適宜 Slack や Qiita:Team での情報共有も行っています。

ほかの部署に影響がありそうな変更点を見つけた場合も、同じように都度共有しています。

## まとめ

* Facebook API バージョンのリリースは、だいたい三ヶ月毎
* Facebook API バージョンの寿命は Graph API と Marketing API で違う
  * Graph API は [Platform Versioning](https://developers.facebook.com/docs/apps/versions) を見る
  * Marketing API は寿命が短いので注意
* 変更点は [Facebook Platform Changelog](https://developers.facebook.com/docs/apps/changelog) 見ればわかる
  * [API Upgrade Tool](https://developers.facebook.com/tools/api_versioning/) も参考に
* 基本的には [Developer News](https://developers.facebook.com/blog/) など、開発者向けブログのフィードを購読する
  * [Developer Settings](https://developers.facebook.com/settings/developer/contact/) から通知を受け取るようにしておくとより良い

以上、Facebook API と長くお付き合いするためのアレコレでした。

