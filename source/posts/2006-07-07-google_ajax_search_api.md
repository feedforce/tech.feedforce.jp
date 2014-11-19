---
title: Google AJAX Search API
date: 2006-07-07 14:48:46
authors: fukunaga
tags: resume, 
---
<p>Official Site
<a href="http://code.google.com/apis/ajaxsearch/">http://code.google.com/apis/ajaxsearch/</a></p>
<p>Developer Forum
<a href="http://groups.google.com/group/Google-AJAX-Search-API">http://groups.google.com/group/Google-AJAX-Search-API</a></p>
<!--more-->
<div>
  <h2><a name="l1"> </a>どうやって使うの？</h2>
  <div>
    <div>
      <h3><a name="l2"> </a>ウェブ検索サンプル</h3>

<pre><code>
Window.onload = function() {
 // seach control 生成
 var sc = new GSearchControl();

 // searcher 追加
 sc.addSearcher(new GwebSearch());

 // search control 描画
 sc.draw(document.getElementById(“search-control”));

 // 検索実行
 sc.execute(“ルート・コミュニケーションズ”);
}
</code></pre>
<ul>
<li><a href="http://map.fkoji.com/gas/helloworld.html">サンプル</a></li>
</ul>
    </div>
  </div>
</div>
<div>
  <h2><a name="l3"> </a>CSS重要</h2>

  <div>
    <div>
      <ul>
<li>スタイルシートをあてないと<a href="http://map.fkoji.com/gas/nostyle.html">こうなる</a></li>
</ul>
<ul>
<li>スタイル自由なのでサイトにあわせてスタイルシートを適用できる</li>
</ul>
<ul>
<li>要素はGoogleのスタイルシート参照</li>

</ul>
<p><a href="http://www.google.com/uds/css/gsearch.css">http://www.google.com/uds/css/gsearch.css</a>
(使っていいか分からんけど使ってます。)</p>
    </div>
  </div>
</div>
<div>
  <h2><a name="l4"> </a>ウェブ検索以外は？</h2>
  <div>

    <div>
      <h3><a name="l5"> </a>addSearcherに放り込む</h3>
<pre><code>
Window.onload = function() {
 // seach control 生成
 var sc = new GSearchControl();

 // searcher 追加
 sc.addSearcher(new GwebSearch());
 sc.addSearcher(new GlocalSearch());
 sc.addSearcher(new GblogSearch());
 sc.addSearcher(new GvideoSearch());

 // search control 描画
 sc.draw(document.getElementById(“search-control”));

 // 検索実行
 sc.execute(“ルート・コミュニケーションズ”);
}
</code></pre>
<ul>
<li><a href="http://map.fkoji.com/gas/allsearch.html">サンプル</a></li>
</ul>
    </div>
  </div>

</div>
<div>
  <h2><a name="l6"> </a>タブにできるよ</h2>
  <div>
    <div>
      <h3><a name="l7"> </a>GdrawOption</h3>
<ul>
<li>DRAW_MODE_TABBED</li>

<li>DRAW_MODE_LINEAR</li>
</ul>
<pre><code>
// draw options
var opt = new GdrawOptions();

// 描画モードの指定
opt.setDrawMode(GSearchControl.DRAW_MODE_TABBED);

// オプションつけて描画
sc.draw(document.getElementById(“search-control”), opt);
</code></pre>
<ul>
<li><a href="http://map.fkoji.com/gas/tabbed.html">サンプル</a></li>
</ul>
    </div>
  </div>
</div>
<div>
  <h2><a name="l8"> </a>検索結果を任意の場所に</h2>

  <div>
    <div>
      <h3><a name="l9"> </a>setRoot(element)</h3>
<pre><code>
// searcher options
var opt = new GsearcherOptions();

// id=“web-search” をセット
opt.setRoot(document.getElementById(“web-search”));

// ウェブ検索はweb-searchの場所に表示
sc.addSearcher(new GwebSearchControl(), opt);

// ブログ検索はデフォルト位置に
sc.addSearcher(new GblogSearchControl);
</code></pre>
<ul>
<li><a href="http://map.fkoji.com/gas/setroot.html">サンプル</a></li>
</ul>
    </div>

  </div>
</div>
<div>
  <h2><a name="l10"> </a>True Potentialはこれらしい</h2>
  <div>
    <div>
      <h3><a name="l11"> </a>setOnKeepCallback</h3>
<pre><code>

// establish a keep callback
sc.setOnKeepCallback(this, function(result) {
 // 要素取得
 var titles = document.getElementById(“result-title”);

 // pタグ生成
 var p = document.createElement(“p”);
 // 検索結果のタイトルをappend
 p.appendChild(document.createTextNode(result.titleNoFormatting));

 // pタグをappend
 titles.appendChild(p);
});
</code></pre>
<ul>
<li><a href="http://map.fkoji.com/gas/keepcallback.html">サンプル</a></li>
</ul>
    </div>
  </div>
</div>
<div>
  <h2><a name="l12"> </a>ラベルを変えられます</h2>
  <div>

    <div>
      <h3><a name="l13"> </a>サイト内検索などで重宝するよ</h3>
<pre><code>
// create a web search
var ws = new GwebSearch();

// サイト内検索設定
ws.setSiteRestriction(“item.rakuten.co.jp”);

// ラベル
ws.setUserDefinedLabel(“楽天商品検索”);

// add searcher
sc.addSearcher(ws);
</code></pre>
<ul>
<li><a href="http://map.fkoji.com/gas/siterestrict.html">サンプル</a></li>
</ul>
    </div>
  </div>

</div>
<div>
  <h2><a name="l14"> </a>まだv0.1なので・・・</h2>
  <div>
    <div>
      <ul>
<li>バグあり<ul>
<li>英語以外のローカル検索に不具合</li>
</ul></li>

</ul>
<ul>
<li>Googleの検索だけどGoogleの検索結果と一致してません</li>
</ul>
<ul>
<li>undocumentedな機能</li>
</ul>
    </div>
  </div>
</div>
<div>
  <h2><a name="l15"> </a>参考ドキュメント</h2>

  <div>
    <div>
      <p>Google AJAX Search API Documentation
<a href="http://code.google.com/apis/ajaxsearch/documentation/">http://code.google.com/apis/ajaxsearch/documentation/</a></p>
    </div>
  </div>
</div>