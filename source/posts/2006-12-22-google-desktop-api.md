---
title: Google Desktop API
date: 2006-12-22 17:49 JST
authors: fukunaga
tags: resume, 
---
<div><div>

  <div>
    <div>
      <p>先日筑波で開催されたGoogleエンジニアの講演を聴いてきたので、今回はGoogle Desktop APIを学習します。</p>
<dl>
<dt>OpenCollege4 - PukiWiki</dt><dd><a href="http://www.osss.cs.tsukuba.ac.jp/kato/wiki/kato/index.php?OpenCollege4">http://www.osss.cs.tsukuba.ac.jp/kato/wiki/kato/index.php?OpenCollege4</a></dd>
</dl>
    </div>
  </div>

</div>
<!--more-->
<div>
  <h2><a name="l0"> </a>関連記事</h2>
  <div>
    <div>
      <ul>
<li><a href="http://codezine.jp/a/article/aid/804.aspx">CodeZine：Google流プログラミングの真髄を筑波大学で見てきた（google）</a></li>
</ul>
    </div>

  </div>
</div>
<div>
  <h2><a name="l1"> </a>ガジェットについて</h2>
  <div>
    <div>
      <p>Googleのガジェットは2種類あります。</p>
<h3><a name="l2"> </a>Universal Gadget</h3>

<p>Googleのパーソナライズドホームに設置できるガジェット</p>
<h3><a name="l3"> </a>Google Desktop Gadget</h3>
<p>Google デスクトップ で動くガジェット</p>
<h3><a name="l4"> </a>今回は後者のほうを扱います。</h3>
    </div>
  </div>
</div>
<div>
  <h2><a name="l5"> </a>はじめに</h2>

  <div>
    <div>
      <h3><a name="l6"> </a>Google Desktopが必要です</h3>
<p><a href="http://desktop.google.com/">http://desktop.google.com/</a></p>
<h3><a name="l7"> </a>Google Desktop SDKを入手します</h3>
<p><a href="http://desktop.google.com/dev/index.html">http://desktop.google.com/dev/index.html</a></p>
<dl>
<dt>SDK のダウンロード</dt><dd><a href="http://desktop.google.com/downloadsdksubmit">http://desktop.google.com/downloadsdksubmit</a></dd>

</dl>
    </div>
  </div>
</div>
<div>
  <h2><a name="l8"> </a>サンプルを見てみる</h2>
  <div>
    <div>
      <p>ファイルを展開</p>

<h3><a name="l9"> </a>Hello Worldのサンプル</h3>
```

GD_SDK\api\samples\scripts\display\HelloWorld

```
<h4><a name="l10"> </a>内容</h4>
```

-1033/
 -strings.xml
-gadget.gmanifest
-main.xml
-plugin.js
-plugin_large.gif
-plugin_small.gif

```
<p>説明していきます</p>
<h5><a name="l11"> </a>main.xml</h5>

<p>メインビューを定義するXML</p>
```

&lt;view width="100" height="100" resizable="true" showCaptionAlways="true" &gt;
  &lt;contentArea name="contentArea" width="100%" height="100%" /&gt;
  &lt;script src="plugin.js"/&gt;
&lt;/view&gt;

```
<h5><a name="l12"> </a>1033/strings.xml</h5>

<p>言語ファイルです。各国の言語でstrings.xmlファイルを用意することで国際化が容易にできます。JavaScriptの変数としても使えます。</p>
```

&lt;strings&gt;
&lt;strTitle&gt;HelloWorld!&lt;/strTitle&gt;
&lt;strHello&gt;HelloWorld!&lt;/strHello&gt;
&lt;strSnippet&gt;Some item information.&lt;/strSnippet&gt;

&lt;strAboutText&gt;HelloWorld! plugin.
Copyright goes here.
More description here&lt;/strAboutText&gt;
&lt;strDescription&gt;Says Hello World&lt;/strDescription&gt;
&lt;/strings&gt;

```
<p>1033はLocal ID(言語ID)で、1033は"English - United States"</p>
<h6><a name="l13"> </a>Microsoftの定義に従ってます</h6>
<p><a href="http://www.microsoft.com/globaldev/reference/lcid-all.mspx">List of Locale ID (LCID) Values as Assigned by Microsoft</a></p>

<h6><a name="l14"> </a>どの言語が選択されるのか</h6>
<p>サイドバーでは、現在のシステムと同じ言語 ID のディレクトリが存在するかど
うかを最初に確認します。 存在する場合は、そのディレクトリの strings.xml
ファイルが読み込まれます。 同じ言語 ID のディレクトリが存在しない場合
で、1033 (アメリカ英語) ディレクトリが存在する場合は、デフォルトでその
ディレクトリの strings.xml ファイルが読み込まれます。</p>
<h5><a name="l15"> </a>gadget.gmanifest</h5>
<p>メタ情報を含むXMLです。マニフェストです。</p>
```

&lt;gadget minimumGoogleDesktopVersion="4.2006.508.0"&gt;
  &lt;about&gt;
    &lt;id&gt;5F1AAC6B-83B9-48e2-804B-E77AD19C9EC8&lt;/id&gt;

    &lt;version&gt;1.0.0.0&lt;/version&gt;
    &lt;author&gt;Google&lt;/author&gt;
    &lt;authorEmail&gt;&lt;/authorEmail&gt;
    &lt;authorWebsite&gt;http://desktop.google.com/plugins.html&lt;/authorWebsite&gt;

    &lt;copyright&gt;Copyright (c) 2006 Google Inc.&lt;/copyright&gt;
    &lt;description&gt;&amp;strDescription;&lt;/description&gt;
    &lt;name&gt;&amp;strTitle;&lt;/name&gt;
    &lt;aboutText&gt;&amp;strAboutText;&lt;/aboutText&gt;

    &lt;smallIcon&gt;plugin_small.gif&lt;/smallIcon&gt;
    &lt;icon&gt;plugin_large.gif&lt;/icon&gt;
  &lt;/about&gt;
&lt;/gadget&gt;

```
<p>&amp;と;で囲まれた文字はstrings.xmlで定義した変数になってます。</p>

<h5><a name="l16"> </a>plugin.js</h5>
<p>ガジェットの動作はJavaScriptで記述します。</p>
```

// Copyright (c) 2006 Google Inc.
// All rights reserved
//
// This file is part of the Google Desktop SDK and may be freely copied
and used.
// To download the latest version of the SDK please visit
// http://desktop.google.com/developer.html

view.caption = strTitle;
contentArea.contentFlags = gddContentFlagHaveDetails;

// Create 1 content item and make it say hello.
var item = new ContentItem();
item.heading = strHello;    // this string is shown in the item
item.snippet = strSnippet;  // this string shown in details view
contentArea.addContentItem(item, gddItemDisplayInSidebar); // add the
item to the display

```
<h6><a name="l17"> </a>viewオブジェクト</h6>
<p>全体の概観</p>
<h6><a name="l18"> </a>contentAreaオブジェクト</h6>
<p>一般的なコンテンツ格納オブジェクト</p>

<h6><a name="l19"> </a>gddContentFlagHaveDetails</h6>
<p>ユーザーがコンテンツ アイテムをクリックしたときに詳細ビューを表示します。</p>
<h4><a name="l20"> </a>実行</h4>
<p>これらのファイルをZIP圧縮して拡張子をggに変更すると、Google デスクトップ で実行できるファイルになります。</p>
    </div>
  </div>
</div>
<div>
  <h2><a name="l21"> </a>作ってみます？</h2>

  <div>
    <div>
      <h3><a name="l22"> </a>ガジェット作成ツールを使いましょう</h3>
```

GD_SDK\api\designer\designer_ja.exe

```
<h3><a name="l23"> </a>サンプルのソースとリファレンスを見ながらゴリゴリ</h3>
<p><a href="http://fkoji.com/gadget/fkoji_sample.zip">http://fkoji.com/gadget/fkoji_sample.zip</a></p>
    </div>

  </div>
</div>
</div>
