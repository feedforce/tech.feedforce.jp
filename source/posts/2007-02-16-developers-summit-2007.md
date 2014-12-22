---
title: デブサミ2007
date: 2007-02-16 18:58 JST
authors: fukunaga
tags: resume, 
---
  
- [Developers Summit 2007](http://www.seshop.com/event/dev/2007/)
- 通称「デブサミ2007」

### 会場

[目黒雅叙園](http://images.google.co.jp/images?q=%E7%9B%AE%E9%BB%92%E9%9B%85%E5%8F%99%E5%9C%92&svnum=10&hl=ja&lr=lang_ja&client=firefox&rls=org.mozilla:ja:official&hs=zmv&start=20&sa=N&ndsp=20)

### 日程

2007/02/14 - 2007/02/15  
初日のみ参加してきました。

<!--more-->  

## Developers Summit 2007
- [Developers Summit 2007](http://www.seshop.com/event/dev/2007/)
- 通称「デブサミ2007」

### 会場

[目黒雅叙園](http://images.google.co.jp/images?q=%E7%9B%AE%E9%BB%92%E9%9B%85%E5%8F%99%E5%9C%92&svnum=10&hl=ja&lr=lang_ja&client=firefox&rls=org.mozilla:ja:official&hs=zmv&start=20&sa=N&ndsp=20)

### 日程

2007/02/14 - 2007/02/15  
初日のみ参加してきました。

## 聴講セッション
- 大規模ウェブサイトのスケールアウトモデル
  - (株)ミクシィ バタラ・ケスマ 氏
- 「Web2.0 on Desktop」が開発者にもたらすもの ～「Apollo」で実現するアプリケーション開発の新潮流～
  - アドビ システムズ(株) 上条晃宏 氏
- PlaggerによるRSS/Atomフィードのマッシュアップ ～Web2.0時代のインターネットPipe操作術～
  - サイボウズ・ラボ(株) 竹迫良範 氏
- JavaScriptの現在と未来 ～今JavaScriptに出来ること / 次世代JavaScriptの勢力図～
  - Shibuya.js 天野仁史 氏
- 出張Shibuyaイベント ～Shibuya.pm presents "Shibuya.js x Shibuya.pl mashup night"～
  - Shibuya.pm / Shibuya.js

主に1番目と2番目について。

## セッション概要

### バタラさん講演

ウェブサーバとデータベースサーバのスケールアウトモデルについて。

#### ウェブサーバ

##### 静的コンテンツ

ロードバランサーとウェブサーバの間にキャッシュサーバを並べる。問題はキャッシュサーバを増やすとウェブサーバへの負荷が増加すること。解決策として、キャッシュサーバを階層化してクラスタ化する方法がある。

キャッシュサーバを階層化すると、すべての階層のキャッシュサーバが同じ容量のキャッシュデータを持つ必要がある。これでは上位階層に低スペックのサーバを置けない。そこでクラスタ化が必要になる。

クラスタ化すると、たとえばアクセスはファイル名からクラスタIDを計算して常に決まったクラスタのキャッシュサーバに転送される。これによりキャッシュサーバは他のクラスタのキャッシュデータを持つ必要がなくなるため、キャパシティを節約できる。

##### 動的コンテンツ

ウェブサーバをクラスタ化する。閲覧用とファイルアップロード用などにサーバのホストを分けるのも良い。コンテンツ全体をキャッシュするのは効率が悪いので、コンテンツの構成要素をキャッシュする。

あと、共有メモリの話とかもあった。

#### データベースサーバ

##### データ分割

すべてのデータが同じDBにあるとレプリケーションの負荷が大きくなるので、データを複数のDBを分ける。データの種類でDBを分ける静的な方法と、プライマリキー、インデックス、ハッシュなどのキーを元にしてDBを分ける方法がある。

パーティションマップの方法にはアルゴリズムベースとマネージャベースがある。アルゴリズムベースでは、キーを元にした計算を実行してマッピング先を求める。マネージャベースでは、パーティションマップを格納したマネージャDBに問い合わせをおこなってマッピング先を求める。

さらに大規模になると、マネージャDBをハッシュマッピングしたり、マネージャDBのスレーブを増やすなどの対処をする必要がある。

### Apollo講演

#### Apolloとは

[Adobe Labs](http://www.adobe.com/go/apollo/)

Adobeのいわゆるウィジェット/ガジェット。デスクトップアプリケーションとウェブアプリケーションの両方の特徴を持つ。HTML+JavaScript+CSS+Flashな開発ができる。

#### 特徴

ローカルファイルにアクセスできるらしいです。ローカルの音楽ファイルの再生とかできます。ただし、FlashがMP3しか対応していないのでMP3しか再生できません。セキュリティが気になります。

#### Apolloアプリケーションの構成要素

##### HTML, JavaScript - WebKit

WebKitとはSafariなどで使われているレンダリングエンジンです。求荷求車ネットワーク( [http://www.wkit.jp/](http://www.wkit.jp/) )ではありません。軽量で実績のあるWebKitを採用したとのこと。

つまりApolloでは既存のHTMLコンテンツを表示できるわけですが、WebKit上で動かないJavaScriptコンテンツは動かないということになります。逆に言うと、Apolloで表示できればSafariでも表示できる(SafariがなくてもSafariの動作検証がわりになる)と言えるのかもしれません。

##### SWF

Flash使えます。Flash上にHTMLコンテンツを埋め込んだアプリケーションが作れます。

##### PDF

Adobeだしね。

#### サーバ接続

##### HTTPリクエスト

FlashではGETとPOSTしか許されなかったHTTPリクエストですが、ApolloではすべてのHTTPリクエストを扱えます。

##### Webサービス

各種Webサービスが使えます。(？)

##### Flex Data Services (FDS)

たとえばFlashオブジェクトとJavaオブジェクトの型を自動変換してくれる「Remoting(AMF)」が使えます。サーバからメッセージをプッシュする「メッセージング」も使えます。

#### 開発環境
- FlexBuilder - EclipsベースのFlex開発ツール。有料です。
- Dreamweaver - Apolloアプリケーションの書き出しに対応予定
- Fireworks - Apolloと連携するかも
- Illustrator - Apolloと連携するかも
- コマンドラインツール - 無料です！！
  - Apollo Developer Tool (ADT)
  - Apollo Debug Lancher (ADL)
- テキストエディタ

#### リリース

開発者向けプレビュー版は2007年3～4月頃になりそう。バージョン1.0を2007年中にリリースしたいとのこと。

#### 講演者

akihiro kamijo  

 [http://weblogs.macromedia.com/akamijo/](http://weblogs.macromedia.com/akamijo/)

### Plaggerの話
- スライド150枚のプレゼン
- 会場(200～300人くらい)の人の中でRSSリーダーを使ったことがある人大多数
- LDRハックがかなりアツイらしい
 - LDR + Greasemonkey + Plagger
  - MVCモデルの革命
- インストールは面倒・・・じゃないよ！
  - Debian
    - apt-get install libplagger-perl
  - FedoraCore
    - yum install perl-Plagger
  - FreeBSD
    - portinstall textproc/p5-plagger
  - Windows
    - ppm install Plagger

メモする暇がありませんでした・・・。

詳細はこちら！！  

 [はてなブックマーク - タグ Plagger](http://b.hatena.ne.jp/t/Plagger?sort=eid)  

(期間限定。今ならデブサミの話題満載)

### amachangのJavaScript
- 会場のほぼ100%がprototype.jsを知っている
- オブジェクト指向の基本はオブジェクトだ！
- new はObject.prototype をクローンするんだ！
- プロトタイプとは必要十分性ではなく類似性だ！
- [jsh](http://www.asahi-net.or.jp/~xe4r-kmt/jsh/jsh.html)

#### JavaScriptのこれから
- Adobe - ActionScript3.0
- Mozilla - Tamarin
- Opera - Opera9.5がいい感じ
- Safari - ユーザビリティに力を入れる？
- Microsoft - 標準化反対？

### Shibuya.js x Shibuya.pm

詳細はこちら！！  

 [はてなブックマーク - タグ shibuya.pm](http://b.hatena.ne.jp/t/shibuya.pm?sort=eid)

(期間限定。今ならデブサミの話題満載)

