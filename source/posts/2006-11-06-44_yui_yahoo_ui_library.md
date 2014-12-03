---
title: YUI (Yahoo! UI Library)
date: 2006-11-06 15:47 JST
authors: akahige
tags: resume, 
---
<div><div>
  <h2><a name="l0"> </a>Yahoo! UI Library</h2>
  <div>
    <div>
      <p>米Yahoo!がBSDライセンスで提供しているオープン・ソースのDHTML + AJAX (+ CSS)なJavaScriptライブラリ。
詳しくはここ <a href="http://developer.yahoo.com/yui/">http://developer.yahoo.com/yui/</a></p>
    </div>
  </div>

</div>
<!--more-->
<div>
  <h2><a name="l1"> </a>ダウンロードしましょう</h2>
  <div>
    <div>
      <p><a href="http://sourceforge.net/projects/yui">http://sourceforge.net/projects/yui</a></p>
<p>現在のバージョン 0.11.4
ダウンロードして自鯖に置いてください</p>
    </div>

  </div>
</div>
<div>
  <h2><a name="l2"> </a>ざっくり見ていきましょう</h2>
  <div>
    <div>
      <h3><a name="l3"> </a>グローバル・オブジェクト</h3>
<p><a href="http://developer.yahoo.com/yui/yahoo/">http://developer.yahoo.com/yui/yahoo/</a></p>

```

&lt;script type="text/javascript" src="yahoo.js" &gt;&lt;/script&gt;

```
<p>YAHOO というオブジェクトが生成。</p>
<h3><a name="l4"> </a>ユーティリティ</h3>
<h4><a name="l5"> </a>Animation</h4>
<p>animation.js</p>
<p><a href="http://developer.yahoo.com/yui/animation/">http://developer.yahoo.com/yui/animation/</a></p>

<p>例</p>
```

var attributes = {
 width: { to: 400 },
 height: { to: 400 }
};

```
```

var myAnim = new YAHOO.util.Anim('test', attributes);
myAnim.animate();

```
<ul>
<li>toは絶対値</li>
<li>byは相対値</li>
<li>fromで初期値</li>
<li>unitで単位</li>

<li>イベント・リスニング</li>
</ul>
```

myAnim.onComplete.subscribe(removeElement);

```
<ul>
<li>backgroundColorもOK</li>
</ul>
```

new YAHOO.util.ColorAnim

```
<ul>
<li>2次元のアニメ</li>
</ul>

```

new YAHOO.util.Motion

```
<ul>
<li>カーブの軌跡も描けます</li>
</ul>
```

var attributes = {
 points: {
  to: [400, 400],
  control: [[800, 300], [-200, 400]]
 }
};
var myAnim = new YAHOO.util.Motion('test', attributes);
myAnim.animate();

```
<ul>
<li>自動スクロール</li>
</ul>
<h3><a name="l6"> </a>Connection Manager</h3>

<p>connection.js</p>
<p>XMLHttpRequestを使ったGETやPOST。</p>
<p><a href="http://developer.yahoo.com/yui/connection/">http://developer.yahoo.com/yui/connection/</a></p>
<h4><a name="l7"> </a>DOM</h4>
<p>dom.js</p>
<p><a href="http://developer.yahoo.com/yui/dom/">http://developer.yahoo.com/yui/dom/</a></p>
<p>たとえば・・・</p>
<ul>
<li>getStyle, setStyle</li>

<li>getXY, setXY</li>
<li>getViewportHeight, getViewportWidth</li>
<li>getElementsByClassName</li>
<li>addClass, removeClass, replaceClass</li>
</ul>
<p>など</p>
<h4><a name="l8"> </a>Drag and Drop</h4>
<p>dragdrop.js</p>
<p><a href="http://developer.yahoo.com/yui/dragdrop/">http://developer.yahoo.com/yui/dragdrop/</a></p>

<h4><a name="l9"> </a>Event</h4>
<p>event.js</p>
<p><a href="http://developer.yahoo.com/yui/event/">http://developer.yahoo.com/yui/event/</a></p>
<h3><a name="l10"> </a>コントロール</h3>
<h4><a name="l11"> </a>AutoComplete</h4>
<p>autocomplete.js</p>
<p><a href="http://developer.yahoo.com/yui/autocomplete/">http://developer.yahoo.com/yui/autocomplete/</a></p>

<h4><a name="l12"> </a>Calendar</h4>
<p>calendar.js</p>
<p><a href="http://developer.yahoo.com/yui/calendar/">http://developer.yahoo.com/yui/calendar/</a></p>
<h4><a name="l13"> </a>Container</h4>
<p>container.js</p>
<p><a href="http://developer.yahoo.com/yui/container/">http://developer.yahoo.com/yui/container/</a></p>
<ul>
<li>Tooltip</li>

<li>Panel</li>
<li>Dialog</li>
<li>SimpleDialog</li>
<li>Module</li>
<li>Overlay</li>
</ul>
<h4><a name="l14"> </a>Logger</h4>
<p>logger.js</p>
<p><a href="http://developer.yahoo.com/yui/logger/">http://developer.yahoo.com/yui/logger/</a>

FireBug, Safari JavaScript Console</p>
<h4><a name="l15"> </a>Menu</h4>
<p>menu.js</p>
<p><a href="http://developer.yahoo.com/yui/menu/">http://developer.yahoo.com/yui/menu/</a></p>
<h4><a name="l16"> </a>Slider</h4>
<p>slider.js</p>
<p><a href="http://developer.yahoo.com/yui/slider">http://developer.yahoo.com/yui/slider</a></p>
<h4><a name="l17"> </a>TreeView</h4>

<p>treeview.js</p>
<p><a href="http://developer.yahoo.com/yui/treeview">http://developer.yahoo.com/yui/treeview</a></p>
<h3><a name="l18"> </a>CSSリソース</h3>
<p><a href="http://developer.yahoo.com/yui/articles/gbs/gbs_browser-chart.html">Aグレード</a>のブラウザをすべてサポート</p>
<h4><a name="l19"> </a>CSS Page Grids</h4>
<p>一つのCSSファイルで100以上のレイアウトが可能です！</p>
<ul>
<li>ソースの順序に依存していません</li>

</ul>
```

&lt;!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
"http://www.w3.org/TR/html4/strict.dtd"&gt;
&lt;!-- layouts require "Standards Mode" rendering,
which the 401-strict doctype triggers --&gt;

&lt;link rel="stylesheet" type="text/css" href="grids.css"&gt;

```
<p>詳細はこちら</p>
<p><a href="http://developer.yahoo.com/yui/grids/">http://developer.yahoo.com/yui/grids/</a></p>
<h4><a name="l20"> </a>Standard CSS Fonts</h4>

```

&lt;link rel="stylesheet" type="text/css" href="fonts.css"&gt;

```
<ul>
<li>一貫したfont-sizeとline-height</li>
<li>OSごとに適切なfont-family</li>
<li>ブラウザでのユーザ操作によるfont-size調整に対応</li>
<li><a href="http://www.mozilla-japan.org/docs/web-developer/quirks/">"Quirks Mode"と"Standards Mode"</a>のどちらでも動く</li>
<li>ブラウザごとの"em"のサイズを統一</li>
</ul>

<h3><a name="l21"> </a>Standard CSS Reset</h3>
<p>ブラウザ間のHTMLデフォルトスタイルの差を取り払ってくれます。</p>
```

&lt;link rel="stylesheet" type="text/css" href="reset.css"&gt;

```
<ul>
<li>h1, h2, ... , h6のfont-sizeを100%</li>
</ul>
```

h1,h2,h3,h4,h5,h6{font-size:100%;}

```
<ul>

<li>margin, paddingを0, borderのリセット</li>
</ul>
```

body,div,dl,dt,dd,ul,ol,li,h1,h2,h3,h4,h5,h6,pre,form,fieldset,input,p,blockquote,th,td{margin:0;padding:0;}
table{border-collapse:collapse;border-spacing:0;}

```
<ul>
<li>strong, em, citeなどのfont-styleとfont-weightをnormalに</li>
</ul>
```

address,caption,cite,code,dfn,em,strong,th,var{font-style:normal;font-weight:normal;}

```
<ul>
<li>fieldsetとimgからボーダを除去</li>
</ul>

```

fieldset,img{border:0;}

```
<ul>
<li>リストからlist-styleを除去</li>
</ul>
```

ol,ul {list-style:none;}

```
<ul>
<li>q要素の引用符を除去</li>
</ul>
```

q:before,q:after{content:'';}

```

<ul>
<li>captionとthを左寄せ</li>
</ul>
```

caption,th {text-align:left;}

```
    </div>
  </div>
</div>
<div>
  <h2><a name="l22"> </a>チートシートあります</h2>

  <div>
    <div>
      <p><a href="http://developer.yahoo.com/yui/docs/assets/yui-0.11-cheatsheets.zip">http://developer.yahoo.com/yui/docs/assets/yui-0.11-cheatsheets.zip</a></p>
    </div>
  </div>
</div>
<div>
  <h2><a name="l23"> </a>これを使ってYahoo!と仲良くしませんか？</h2>

  <div>
    <div>

    </div>
  </div>
  </div>
</div>
