---
title: Google Desktop API
date: 2006-12-22 17:49 JST
authors: fukunaga
tags: resume, 
---
先日筑波で開催されたGoogleエンジニアの講演を聴いてきたので、今回はGoogle Desktop APIを学習します。

<dl>
<dt>OpenCollege4 - PukiWiki</dt>
<dd><a href="http://www.osss.cs.tsukuba.ac.jp/kato/wiki/kato/index.php?OpenCollege4">http://www.osss.cs.tsukuba.ac.jp/kato/wiki/kato/index.php?OpenCollege4</a></dd>
</dl>

<!--more-->  

## 関連記事

- [CodeZine：Google流プログラミングの真髄を筑波大学で見てきた（google）](http://codezine.jp/a/article/aid/804.aspx)

## ガジェットについて

Googleのガジェットは2種類あります。

### Universal Gadget

Googleのパーソナライズドホームに設置できるガジェット

### Google Desktop Gadget

Google デスクトップ で動くガジェット

### 今回は後者のほうを扱います。

## はじめに

### Google Desktopが必要です

[http://desktop.google.com/](http://desktop.google.com/)

### Google Desktop SDKを入手します

[http://desktop.google.com/dev/index.html](http://desktop.google.com/dev/index.html)

<dl>
<dt>SDK のダウンロード</dt>
<dd><a href="http://desktop.google.com/downloadsdksubmit">http://desktop.google.com/downloadsdksubmit</a></dd>
</dl>

## サンプルを見てみる

ファイルを展開

### Hello Worldのサンプル

```
GD_SDK\api\samples\scripts\display\HelloWorld
```

#### 内容

```
-1033/
 -strings.xml
-gadget.gmanifest
-main.xml
-plugin.js
-plugin_large.gif
-plugin_small.gif
```

説明していきます

##### main.xml

メインビューを定義するXML

```
<view width="100" height="100" resizable="true" showCaptionAlways="true" >
  <contentArea name="contentArea" width="100%" height="100%" />
  <script src="plugin.js"/>
</view>
```

##### 1033/strings.xml

言語ファイルです。各国の言語でstrings.xmlファイルを用意することで国際化が容易にできます。JavaScriptの変数としても使えます。

```
<strings>
<strTitle>HelloWorld!</strTitle>
<strHello>HelloWorld!</strHello>
<strSnippet>Some item information.</strSnippet>

<strAboutText>HelloWorld! plugin.
Copyright goes here.
More description here</strAboutText>
<strDescription>Says Hello World</strDescription>
</strings>
```

1033はLocal ID(言語ID)で、1033は"English - United States"

###### Microsoftの定義に従ってます

[List of Locale ID (LCID) Values as Assigned by Microsoft](http://www.microsoft.com/globaldev/reference/lcid-all.mspx)

###### どの言語が選択されるのか

サイドバーでは、現在のシステムと同じ言語 ID のディレクトリが存在するかど うかを最初に確認します。 存在する場合は、そのディレクトリの strings.xml ファイルが読み込まれます。 同じ言語 ID のディレクトリが存在しない場合 で、1033 (アメリカ英語) ディレクトリが存在する場合は、デフォルトでその ディレクトリの strings.xml ファイルが読み込まれます。

##### gadget.gmanifest

メタ情報を含むXMLです。マニフェストです。

```
<gadget minimumGoogleDesktopVersion="4.2006.508.0">
  <about>
    <id>5F1AAC6B-83B9-48e2-804B-E77AD19C9EC8</id>

 <version>1.0.0.0</version>
    <author>Google</author>
    <authorEmail></authorEmail>
    <authorWebsite>http://desktop.google.com/plugins.html</authorWebsite>

 <copyright>Copyright (c) 2006 Google Inc.</copyright>
    <description>&strDescription;</description>
    <name>&strTitle;</name>
    <aboutText>&strAboutText;</aboutText>

 <smallIcon>plugin_small.gif</smallIcon>
    <icon>plugin_large.gif</icon>
  </about>
</gadget>
```

&と;で囲まれた文字はstrings.xmlで定義した変数になってます。

##### plugin.js

ガジェットの動作はJavaScriptで記述します。

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
item.heading = strHello; // this string is shown in the item
item.snippet = strSnippet; // this string shown in details view
contentArea.addContentItem(item, gddItemDisplayInSidebar); // add the
item to the display
```

###### viewオブジェクト

全体の概観

###### contentAreaオブジェクト

一般的なコンテンツ格納オブジェクト

###### gddContentFlagHaveDetails

ユーザーがコンテンツ アイテムをクリックしたときに詳細ビューを表示します。

#### 実行

これらのファイルをZIP圧縮して拡張子をggに変更すると、Google デスクトップ で実行できるファイルになります。

## 作ってみます？

### ガジェット作成ツールを使いましょう

```
GD_SDK\api\designer\designer_ja.exe
```

### サンプルのソースとリファレンスを見ながらゴリゴリ

[http://fkoji.com/gadget/fkoji\_sample.zip](http://fkoji.com/gadget/fkoji_sample.zip)

