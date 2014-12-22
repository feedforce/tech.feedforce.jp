---
title: YUI (Yahoo! UI Library)
date: 2006-11-06 15:47 JST
authors: akahige
tags: resume, 
---
## Yahoo! UI Library

米Yahoo!がBSDライセンスで提供しているオープン・ソースのDHTML + AJAX (+ CSS)なJavaScriptライブラリ。 詳しくはここ [http://developer.yahoo.com/yui/](http://developer.yahoo.com/yui/)

<!--more-->  

## ダウンロードしましょう

[http://sourceforge.net/projects/yui](http://sourceforge.net/projects/yui)

現在のバージョン 0.11.4 ダウンロードして自鯖に置いてください

## ざっくり見ていきましょう

### グローバル・オブジェクト

[http://developer.yahoo.com/yui/yahoo/](http://developer.yahoo.com/yui/yahoo/)

```html
<script type="text/javascript" src="yahoo.js" ></script>
```

YAHOO というオブジェクトが生成。

### ユーティリティ

#### Animation

animation.js

[http://developer.yahoo.com/yui/animation/](http://developer.yahoo.com/yui/animation/)

例

```javascript
var attributes = {
 width: { to: 400 },
 height: { to: 400 }
};
```

```javascript
var myAnim = new YAHOO.util.Anim('test', attributes);
myAnim.animate();
```
- toは絶対値
- byは相対値
- fromで初期値
- unitで単位
- イベント・リスニング

```javascript
myAnim.onComplete.subscribe(removeElement);
```

- backgroundColorもOK

```javascript
new YAHOO.util.ColorAnim
```

- 2次元のアニメ

```javascript
new YAHOO.util.Motion
```

- カーブの軌跡も描けます

```javascript
var attributes = {
 points: {
  to: [400, 400],
  control: [[800, 300], [-200, 400]]
 }
};
var myAnim = new YAHOO.util.Motion('test', attributes);
myAnim.animate();
```

- 自動スクロール

### Connection Manager

connection.js

XMLHttpRequestを使ったGETやPOST。

[http://developer.yahoo.com/yui/connection/](http://developer.yahoo.com/yui/connection/)

#### DOM

dom.js

[http://developer.yahoo.com/yui/dom/](http://developer.yahoo.com/yui/dom/)

たとえば・・・
- getStyle, setStyle
- getXY, setXY
- getViewportHeight, getViewportWidth
- getElementsByClassName
- addClass, removeClass, replaceClass

など

#### Drag and Drop

dragdrop.js

[http://developer.yahoo.com/yui/dragdrop/](http://developer.yahoo.com/yui/dragdrop/)

#### Event

event.js

[http://developer.yahoo.com/yui/event/](http://developer.yahoo.com/yui/event/)

### コントロール

#### AutoComplete

autocomplete.js

[http://developer.yahoo.com/yui/autocomplete/](http://developer.yahoo.com/yui/autocomplete/)

#### Calendar

calendar.js

[http://developer.yahoo.com/yui/calendar/](http://developer.yahoo.com/yui/calendar/)

#### Container

container.js

[http://developer.yahoo.com/yui/container/](http://developer.yahoo.com/yui/container/)
- Tooltip
- Panel
- Dialog
- SimpleDialog
- Module
- Overlay

#### Logger

logger.js

[http://developer.yahoo.com/yui/logger/](http://developer.yahoo.com/yui/logger/)

FireBug, Safari JavaScript Console

#### Menu

menu.js

[http://developer.yahoo.com/yui/menu/](http://developer.yahoo.com/yui/menu/)

#### Slider

slider.js

[http://developer.yahoo.com/yui/slider](http://developer.yahoo.com/yui/slider)

#### TreeView

treeview.js

[http://developer.yahoo.com/yui/treeview](http://developer.yahoo.com/yui/treeview)

### CSSリソース

[Aグレード](http://developer.yahoo.com/yui/articles/gbs/gbs_browser-chart.html)のブラウザをすべてサポート

#### CSS Page Grids

一つのCSSファイルで100以上のレイアウトが可能です！
- ソースの順序に依存していません

```html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
"http://www.w3.org/TR/html4/strict.dtd">
<!-- layouts require "Standards Mode" rendering,
which the 401-strict doctype triggers -->

<link rel="stylesheet" type="text/css" href="grids.css">
```

詳細はこちら

[http://developer.yahoo.com/yui/grids/](http://developer.yahoo.com/yui/grids/)

#### Standard CSS Fonts

```html
<link rel="stylesheet" type="text/css" href="fonts.css">
```

- 一貫したfont-sizeとline-height
- OSごとに適切なfont-family
- ブラウザでのユーザ操作によるfont-size調整に対応
- ["Quirks Mode"と"Standards Mode"](http://www.mozilla-japan.org/docs/web-developer/quirks/)のどちらでも動く
- ブラウザごとの"em"のサイズを統一

### Standard CSS Reset

ブラウザ間のHTMLデフォルトスタイルの差を取り払ってくれます。

```html
<link rel="stylesheet" type="text/css" href="reset.css">
```
- h1, h2, ... , h6のfont-sizeを100%

```css
h1,h2,h3,h4,h5,h6{font-size:100%;}
```
- margin, paddingを0, borderのリセット

```css
body,div,dl,dt,dd,ul,ol,li,h1,h2,h3,h4,h5,h6,pre,form,fieldset,input,p,blockquote,th,td{margin:0;padding:0;}
table{border-collapse:collapse;border-spacing:0;}
```
- strong, em, citeなどのfont-styleとfont-weightをnormalに

```css
address,caption,cite,code,dfn,em,strong,th,var{font-style:normal;font-weight:normal;}
```
- fieldsetとimgからボーダを除去

```css
fieldset,img{border:0;}
```
- リストからlist-styleを除去

```css
ol,ul {list-style:none;}
```

- q要素の引用符を除去

```css
q:before,q:after{content:'';}
```

- captionとthを左寄せ

```css
caption,th {text-align:left;}
```

## チートシートあります

[http://developer.yahoo.com/yui/docs/assets/yui-0.11-cheatsheets.zip](http://developer.yahoo.com/yui/docs/assets/yui-0.11-cheatsheets.zip)

## これを使ってYahoo!と仲良くしませんか？
