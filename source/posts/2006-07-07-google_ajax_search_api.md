---
title: Google AJAX Search API
date: 2006-07-07 14:48 JST
authors: fukunaga
tags: resume, 
---
Official Site
[http://code.google.com/apis/ajaxsearch/](http://code.google.com/apis/ajaxsearch/)

Developer Forum
[http://groups.google.com/group/Google-AJAX-Search-API](http://groups.google.com/group/Google-AJAX-Search-API)

<!--more-->  

## どうやって使うの？

### ウェブ検索サンプル

```javascript
Window.onload = function() {
 // seach control 生成
 var sc = new GSearchControl();

 // searcher 追加
 sc.addSearcher(new GwebSearch());

 // search control 描画
 sc.draw(document.getElementById("search-control"));

 // 検索実行
 sc.execute("ルート・コミュニケーションズ");
}
```

- [サンプル](http://map.fkoji.com/gas/helloworld.html)

## CSS重要

- スタイルシートをあてないと [こうなる](http://map.fkoji.com/gas/nostyle.html)
- スタイル自由なのでサイトにあわせてスタイルシートを適用できる
- 要素はGoogleのスタイルシート参照

[http://www.google.com/uds/css/gsearch.css](http://www.google.com/uds/css/gsearch.css)(使っていいか分からんけど使ってます。)

## ウェブ検索以外は？

### addSearcherに放り込む

```
Window.onload = function() {
 // seach control 生成
 var sc = new GSearchControl();

 // searcher 追加
 sc.addSearcher(new GwebSearch());
 sc.addSearcher(new GlocalSearch());
 sc.addSearcher(new GblogSearch());
 sc.addSearcher(new GvideoSearch());

 // search control 描画
 sc.draw(document.getElementById("search-control"));

 // 検索実行
 sc.execute("ルート・コミュニケーションズ");
}
```

- [サンプル](http://map.fkoji.com/gas/allsearch.html)

## タブにできるよ

### GdrawOption

- DRAW\_MODE\_TABBED
- DRAW\_MODE\_LINEAR

```javascript
// draw options
var opt = new GdrawOptions();

// 描画モードの指定
opt.setDrawMode(GSearchControl.DRAW_MODE_TABBED);

// オプションつけて描画
sc.draw(document.getElementById("search-control"), opt);
```

- [サンプル](http://map.fkoji.com/gas/tabbed.html)

## 検索結果を任意の場所に

### setRoot(element)

```javascript
// searcher options
var opt = new GsearcherOptions();

// id="web-search" をセット
opt.setRoot(document.getElementById("web-search"));

// ウェブ検索はweb-searchの場所に表示
sc.addSearcher(new GwebSearchControl(), opt);

// ブログ検索はデフォルト位置に
sc.addSearcher(new GblogSearchControl);
```

- [サンプル](http://map.fkoji.com/gas/setroot.html)

## True Potentialはこれらしい

### setOnKeepCallback

```javascript
// establish a keep callback
sc.setOnKeepCallback(this, function(result) {
 // 要素取得
 var titles = document.getElementById("result-title");

 // pタグ生成
 var p = document.createElement("p");
 // 検索結果のタイトルをappend
 p.appendChild(document.createTextNode(result.titleNoFormatting));

 // pタグをappend
 titles.appendChild(p);
});
```

- [サンプル](http://map.fkoji.com/gas/keepcallback.html)

## ラベルを変えられます

### サイト内検索などで重宝するよ

```javascript
// create a web search
var ws = new GwebSearch();

// サイト内検索設定
ws.setSiteRestriction("item.rakuten.co.jp");

// ラベル
ws.setUserDefinedLabel("楽天商品検索");

// add searcher
sc.addSearcher(ws);
```

- [サンプル](http://map.fkoji.com/gas/siterestrict.html)

## まだv0.1なので・・・

- バグあり
  - 英語以外のローカル検索に不具合
- Googleの検索だけどGoogleの検索結果と一致してません
- undocumentedな機能

## 参考ドキュメント

Google AJAX Search API Documentationjavascript
[http://code.google.com/apis/ajaxsearch/documentation/](http://code.google.com/apis/ajaxsearch/documentation/)

