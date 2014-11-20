---
title: デブサミ2007
date: 2007-02-16 18:58 JST
authors: fukunaga
tags: resume, 
---
      <ul>
<li><a href="http://www.seshop.com/event/dev/2007/" class="external">Developers Summit 2007</a></li>
<li>通称「デブサミ2007」</li>
</ul>
<h3><a name="l1"><span class="sanchor"> </span></a>会場</h3>
<p><a href="http://images.google.co.jp/images?q=%E7%9B%AE%E9%BB%92%E9%9B%85%E5%8F%99%E5%9C%92&amp;svnum=10&amp;hl=ja&amp;lr=lang_ja&amp;client=firefox&amp;rls=org.mozilla:ja:official&amp;hs=zmv&amp;start=20&amp;sa=N&amp;ndsp=20" class="external">目黒雅叙園</a></p>
<h3><a name="l2"><span class="sanchor"> </span></a>日程</h3>

<p>2007/02/14 - 2007/02/15<br>
初日のみ参加してきました。</p>
<!--more-->
<div>
<div class="day">
  <h2><span class="date"><a name="l0"> </a></span><span class="title">Developers Summit 2007</span></h2>
  <div class="body">

    <div class="section">
      <ul>
<li><a href="http://www.seshop.com/event/dev/2007/" class="external">Developers Summit 2007</a></li>
<li>通称「デブサミ2007」</li>
</ul>
<h3><a name="l1"><span class="sanchor"> </span></a>会場</h3>
<p><a href="http://images.google.co.jp/images?q=%E7%9B%AE%E9%BB%92%E9%9B%85%E5%8F%99%E5%9C%92&amp;svnum=10&amp;hl=ja&amp;lr=lang_ja&amp;client=firefox&amp;rls=org.mozilla:ja:official&amp;hs=zmv&amp;start=20&amp;sa=N&amp;ndsp=20" class="external">目黒雅叙園</a></p>
<h3><a name="l2"><span class="sanchor"> </span></a>日程</h3>

<p>2007/02/14 - 2007/02/15<br>
初日のみ参加してきました。</p>
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l3"> </a></span><span class="title">聴講セッション</span></h2>
  <div class="body">
    <div class="section">

      <ul>
<li>大規模ウェブサイトのスケールアウトモデル<ul>
<li>(株)ミクシィ バタラ・ケスマ 氏</li>
</ul></li>
<li>「Web2.0 on Desktop」が開発者にもたらすもの ～「Apollo」で実現するアプリケーション開発の新潮流～<ul>
<li>アドビ システムズ(株) 上条晃宏 氏</li>
</ul></li>
<li>PlaggerによるRSS/Atomフィードのマッシュアップ ～Web2.0時代のインターネットPipe操作術～<ul>
<li>サイボウズ・ラボ(株) 竹迫良範 氏</li>
</ul></li>

<li>JavaScriptの現在と未来 ～今JavaScriptに出来ること / 次世代JavaScriptの勢力図～<ul>
<li>Shibuya.js 天野仁史 氏</li>
</ul></li>
<li>出張Shibuyaイベント ～Shibuya.pm presents "Shibuya.js x Shibuya.pl mashup night"～<ul>
<li>Shibuya.pm / Shibuya.js</li>
</ul></li>
</ul>
<p>主に1番目と2番目について。</p>
    </div>
  </div>

</div>
<div class="day">
  <h2><span class="date"><a name="l4"> </a></span><span class="title">セッション概要</span></h2>
  <div class="body">
    <div class="section">
      <h3><a name="l5"><span class="sanchor"> </span></a>バタラさん講演</h3>
<p>ウェブサーバとデータベースサーバのスケールアウトモデルについて。</p>
<h4><a name="l6"> </a>ウェブサーバ</h4>

<h5><a name="l7"> </a>静的コンテンツ</h5>
<p>ロードバランサーとウェブサーバの間にキャッシュサーバを並べる。問題はキャッシュサーバを増やすとウェブサーバへの負荷が増加すること。解決策として、キャッシュサーバを階層化してクラスタ化する方法がある。</p>
<p>キャッシュサーバを階層化すると、すべての階層のキャッシュサーバが同じ容量のキャッシュデータを持つ必要がある。これでは上位階層に低スペックのサーバを置けない。そこでクラスタ化が必要になる。</p>
<p>クラスタ化すると、たとえばアクセスはファイル名からクラスタIDを計算して常に決まったクラスタのキャッシュサーバに転送される。これによりキャッシュサーバは他のクラスタのキャッシュデータを持つ必要がなくなるため、キャパシティを節約できる。</p>
<h5><a name="l8"> </a>動的コンテンツ</h5>
<p>ウェブサーバをクラスタ化する。閲覧用とファイルアップロード用などにサーバのホストを分けるのも良い。コンテンツ全体をキャッシュするのは効率が悪いので、コンテンツの構成要素をキャッシュする。</p>
<p>あと、共有メモリの話とかもあった。</p>
<h4><a name="l9"> </a>データベースサーバ</h4>

<h5><a name="l10"> </a>データ分割</h5>
<p>すべてのデータが同じDBにあるとレプリケーションの負荷が大きくなるので、データを複数のDBを分ける。データの種類でDBを分ける静的な方法と、プライマリキー、インデックス、ハッシュなどのキーを元にしてDBを分ける方法がある。</p>
<p>パーティションマップの方法にはアルゴリズムベースとマネージャベースがある。アルゴリズムベースでは、キーを元にした計算を実行してマッピング先を求める。マネージャベースでは、パーティションマップを格納したマネージャDBに問い合わせをおこなってマッピング先を求める。</p>
<p>さらに大規模になると、マネージャDBをハッシュマッピングしたり、マネージャDBのスレーブを増やすなどの対処をする必要がある。</p>
<h3><a name="l11"><span class="sanchor"> </span></a>Apollo講演</h3>
<h4><a name="l12"> </a>Apolloとは</h4>
<p><a href="http://www.adobe.com/go/apollo/" class="external">Adobe Labs</a></p>

<p>Adobeのいわゆるウィジェット/ガジェット。デスクトップアプリケーションとウェブアプリケーションの両方の特徴を持つ。HTML+JavaScript+CSS+Flashな開発ができる。</p>
<h4><a name="l13"> </a>特徴</h4>
<p>ローカルファイルにアクセスできるらしいです。ローカルの音楽ファイルの再生とかできます。ただし、FlashがMP3しか対応していないのでMP3しか再生できません。セキュリティが気になります。</p>
<h4><a name="l14"> </a>Apolloアプリケーションの構成要素</h4>
<h5><a name="l15"> </a>HTML, JavaScript - WebKit</h5>
<p>WebKitとはSafariなどで使われているレンダリングエンジンです。求荷求車ネットワーク( <a href="http://www.wkit.jp/" class="external">http://www.wkit.jp/</a> )ではありません。軽量で実績のあるWebKitを採用したとのこと。</p>

<p>つまりApolloでは既存のHTMLコンテンツを表示できるわけですが、WebKit上で動かないJavaScriptコンテンツは動かないということになります。逆に言うと、Apolloで表示できればSafariでも表示できる(SafariがなくてもSafariの動作検証がわりになる)と言えるのかもしれません。</p>
<h5><a name="l16"> </a>SWF</h5>
<p>Flash使えます。Flash上にHTMLコンテンツを埋め込んだアプリケーションが作れます。</p>
<h5><a name="l17"> </a>PDF</h5>
<p>Adobeだしね。</p>
<h4><a name="l18"> </a>サーバ接続</h4>
<h5><a name="l19"> </a>HTTPリクエスト</h5>

<p>FlashではGETとPOSTしか許されなかったHTTPリクエストですが、ApolloではすべてのHTTPリクエストを扱えます。</p>
<h5><a name="l20"> </a>Webサービス</h5>
<p>各種Webサービスが使えます。(？)</p>
<h5><a name="l21"> </a>Flex Data Services (FDS)</h5>
<p>たとえばFlashオブジェクトとJavaオブジェクトの型を自動変換してくれる「Remoting(AMF)」が使えます。サーバからメッセージをプッシュする「メッセージング」も使えます。</p>
<h4><a name="l22"> </a>開発環境</h4>
<ul>
<li>FlexBuilder - EclipsベースのFlex開発ツール。有料です。</li>

<li>Dreamweaver - Apolloアプリケーションの書き出しに対応予定</li>
<li>Fireworks - Apolloと連携するかも</li>
<li>Illustrator - Apolloと連携するかも</li>
<li>コマンドラインツール - 無料です！！<ul>
<li>Apollo Developer Tool (ADT)</li>
<li>Apollo Debug Lancher (ADL)</li>
</ul></li>
<li>テキストエディタ</li>
</ul>
<h4><a name="l23"> </a>リリース</h4>

<p>開発者向けプレビュー版は2007年3～4月頃になりそう。バージョン1.0を2007年中にリリースしたいとのこと。</p>
<h4><a name="l24"> </a>講演者</h4>
<p>akihiro kamijo
<a href="http://weblogs.macromedia.com/akamijo/" class="external">http://weblogs.macromedia.com/akamijo/</a></p>
<h3><a name="l25"><span class="sanchor"> </span></a>Plaggerの話</h3>
<ul>
<li>スライド150枚のプレゼン</li>
<li>会場(200～300人くらい)の人の中でRSSリーダーを使ったことがある人大多数</li>
<li>LDRハックがかなりアツイらしい<ul>

<li>LDR + Greasemonkey + Plagger</li>
<li>MVCモデルの革命</li>
</ul></li>
<li>インストールは面倒・・・じゃないよ！<ul>
<li>Debian<ul>
<li>apt-get install libplagger-perl</li>
</ul></li>
<li>FedoraCore<ul>
<li>yum install perl-Plagger</li>
</ul></li>

<li>FreeBSD<ul>
<li>portinstall textproc/p5-plagger</li>
</ul></li>
<li>Windows<ul>
<li>ppm install Plagger</li>
</ul></li>
</ul></li>
</ul>
<p>メモする暇がありませんでした・・・。</p>
<p>詳細はこちら！！<br>
<a href="http://b.hatena.ne.jp/t/Plagger?sort=eid" class="external">はてなブックマーク - タグ Plagger</a><br>

(期間限定。今ならデブサミの話題満載)</p>
<h3><a name="l26"><span class="sanchor"> </span></a>amachangのJavaScript</h3>
<ul>
<li>会場のほぼ100%がprototype.jsを知っている</li>
<li>オブジェクト指向の基本はオブジェクトだ！</li>
<li>new はObject.prototype をクローンするんだ！</li>
<li>プロトタイプとは必要十分性ではなく類似性だ！</li>
<li><a href="http://www.asahi-net.or.jp/~xe4r-kmt/jsh/jsh.html" class="external">jsh</a></li>
</ul>

<h4><a name="l27"> </a>JavaScriptのこれから</h4>
<ul>
<li>Adobe - ActionScript3.0</li>
<li>Mozilla - Tamarin</li>
<li>Opera - Opera9.5がいい感じ</li>
<li>Safari - ユーザビリティに力を入れる？</li>
<li>Microsoft - 標準化反対？</li>
</ul>
<h3><a name="l28"><span class="sanchor"> </span></a>Shibuya.js x Shibuya.pm</h3>

<p>詳細はこちら！！<br>
<a href="http://b.hatena.ne.jp/t/shibuya.pm?sort=eid" class="external">はてなブックマーク - タグ shibuya.pm</a></p>
<p>(期間限定。今ならデブサミの話題満載)</p>
    </div>
  </div>
</div>
</div>