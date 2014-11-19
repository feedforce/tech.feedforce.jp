---
title: The Atom Syndication Format
date: 2006-10-20 15:12:33
authors: yanagi
tags: resume, 
---
<p>RSS の代替を目指した新しいフォーマット</p>

<p>2003年6月 IBM の Sam Ruby が仕様策定のための行動を開始</p>

<p>Atom は仕様群の総称</p>

<ul>
<li>The Atom Syndication Format (コンテンツ配信のためのフィードフォーマット)</li>
<li>The Atom Publishing Protocol (コンテンツ編集のためのプロトコル)</li>
<li>Atom Feed Autodiscovery (フィードを自動的に見つけるための記述)</li>
</ul>
<!--more-->
<div><div>
  <h2><a name="l0"> </a>Atom 配信フォーマットとは</h2>
  <div>
    <div>
      <p>RSS の代替を目指した新しいフォーマット</p>
<p>2003年6月 IBM の Sam Ruby が仕様策定のための行動を開始</p>
<p>Atom は仕様群の総称</p>

<ul>
<li>The Atom Syndication Format (コンテンツ配信のためのフィードフォーマット)</li>
<li>The Atom Publishing Protocol (コンテンツ編集のためのプロトコル)</li>
<li>Atom Feed Autodiscovery (フィードを自動的に見つけるための記述)</li>
</ul>
<p>Atom の目指すもの</p>
<ul>
<li>特定のベンダに依存しない</li>
<li>全ての人が自由に実装できる</li>
<li>誰でも自由に拡張できる</li>

<li>明確かつ完全に仕様が決められている</li>
</ul>
<p>IETF によって仕様が管理されている</p>
<ul>
<li>RFC4287 <a href="http://www.ietf.org/rfc/rfc4287">http://www.ietf.org/rfc/rfc4287</a></li>
</ul>
    </div>
  </div>
</div>
<div>
  <h2><a name="l1"> </a>Atom コンストラクト</h2>

  <div>
    <div>
      <p>Atom フォーマット内で使われる共通のデータ構造</p>
<h3><a name="l2"> </a>Text コンストラクト</h3>
<p>type 属性が "text" "html" "xhtml" のいずれか</p>
<h4><a name="l3"> </a>Text</h4>
<ul>
<li>子要素を含んではいけない。</li>

</ul>
<pre><code>
&lt;title type="text"&gt;
  Less: &amp;lt;
&lt;/title&gt;
</code></pre>
<h4><a name="l4"> </a>HTML</h4>
<ul>
<li>子要素を含んではいけない。</li>
<li>マークアップは全てエスケープしなければならない。</li>

<li>HTML の &lt;div&gt; の中に直接現れる形にすべき</li>
</ul>
<pre><code>
&lt;title type="html"&gt;
  Less: &amp;lt;em&gt; &amp;amp;lt; &amp;lt;/em&gt;
&lt;/title&gt;

</code></pre>
<h4><a name="l5"> </a>XHTML</h4>
<ul>
<li>1 つ の XHTML div 要素でなければならない。</li>
<li>div 要素そのものをコンテンツの一部とみなしてはならない。</li>
</ul>
<pre><code>
&lt;title type="xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml"&gt;
  &lt;xhtml:div&gt;
    Less: &lt;xhtml:em&gt; &amp;lt; &lt;/xhtml:em&gt;

  &lt;/xhtml:div&gt;
&lt;/title&gt;
</code></pre>
<h3><a name="l6"> </a>Person コンストラクト</h3>
<p>Person コンストラクト内には、1 個の atom:name 要素と
0 個または 1 個の atom:uri 要素、atom:email 要素を含む。</p>
<h4><a name="l7"> </a>atom:name 要素</h4>
<p>人物の名前。人間が読める形式。</p>
<h4><a name="l8"> </a>atom:uri 要素</h4>

<p>人物に関連付けられた IRI。</p>
<h4><a name="l9"> </a>atom:email 要素</h4>
<p>人物に関連付けられたメールアドレス。</p>
<h3><a name="l10"> </a>Date コンストラクト</h3>
<p>RFC3339 の date-time 形式</p>
<pre><code>
&lt;updated&gt;2003-12-13T18:30:02Z&lt;/updated&gt;

&lt;updated&gt;2003-12-13T18:30:02.25Z&lt;/updated&gt;
&lt;updated&gt;2003-12-13T18:30:02+01:00&lt;/updated&gt;
&lt;updated&gt;2003-12-13T18:30:02.25+01:00&lt;/updated&gt;
</code></pre>
    </div>
  </div>

</div>
<div>
  <h2><a name="l11"> </a>Atom フィードの構造</h2>
  <div>
    <div>
      <h3><a name="l12"> </a>atom:feed 要素内の必須要素</h3>
<p>ルートは atom:feed 要素。feed 要素内には次の要素が必須。</p>
<ul>

<li>atom:id</li>
<li>atom:title</li>
<li>atom:updated</li>
</ul>
<h4><a name="l13"> </a>atom:id 要素</h4>
<p>フィードの一意な識別子。IRI でなくてはならない。
Atom フィードが移転・再発行などされたとしても、atom:id 要素を変えてはいけない。</p>
<h4><a name="l14"> </a>atom:title 要素</h4>
<p>フィードのタイトル。</p>

<p>Text コンストラクト。</p>
<h4><a name="l15"> </a>atom:updated 要素</h4>
<p>フィードに関して、配信者が重要だと考える更新が行われた日時。
フィードが修正されたからと言って、必ずこの要素を更新しなければならないわけではない。</p>
<p>Date コンストラクト。</p>
<h3><a name="l16"> </a>atom:feed 要素内の任意要素</h3>
<h4><a name="l17"> </a>atom:author 要素</h4>
<p>著者を表わす。</p>

<p>Person コンストラクト。</p>
<p>atom:feed 要素は 1 個以上の atom:feed 要素を含まなければならないが
全ての atom:entry 要素が atom:author 要素を含んでいれば、省略できる。</p>
<h4><a name="l18"> </a>atom:category 要素</h4>
<p>カテゴリ情報</p>
<h4><a name="l19"> </a>atom:contributor 要素</h4>
<p>貢献者。</p>
<p>Person コンストラクト。</p>
<h4><a name="l20"> </a>atom:generator 要素</h4>

<p>フィード生成に行なわれたエージェント。</p>
<p>uri 要素と version 要素を子要素に持てる。</p>
<h4><a name="l21"> </a>atom:icon 要素</h4>
<p>フィードのアイコン画像の IRI。</p>
<h4><a name="l22"> </a>atom:link 要素</h4>
<h4><a name="l23"> </a>atom:logo 要素</h4>
<p>フィードのロゴ画像の IRI。</p>

<h4><a name="l24"> </a>atom:rights 要素</h4>
<p>フィードの権利情報。</p>
<p>Text コンストラクト。</p>
<h4><a name="l25"> </a>atom:subtitle 要素</h4>
<p>サブタイトル。</p>
<p>Text コンストラクト。</p>
<h4><a name="l26"> </a>atom:entry 要素</h4>

<p>個々のエントリ。
後述</p>
<h3><a name="l27"> </a>atom:entry 要素内の必須要素</h3>
<ul>
<li>atom:id 要素</li>
<li>atom:title 要素</li>
<li>atom:updated 要素</li>
</ul>
<h3><a name="l28"> </a>atom:entry 要素内の任意要素</h3>
<h4><a name="l29"> </a>atom:author 要素</h4>

<h4><a name="l30"> </a>atom:category 要素</h4>
<h4><a name="l31"> </a>atom:content 要素</h4>
<p>エントリのコンテンツまたはコンテンツへのリンクを表わす要素。</p>
<h4><a name="l32"> </a>atom:contributor 要素</h4>
<h4><a name="l33"> </a>atom:link 要素</h4>
<h4><a name="l34"> </a>atom:published 要素</h4>

<p>エントリが生まれるイベントに関連付けられた日時。</p>
<p>Date コンストラクト。</p>
<h4><a name="l35"> </a>atom:rights 要素</h4>
<h4><a name="l36"> </a>atom:source 要素</h4>
<p>atom:entry が他のフィードから複製されたとき、
その元となる atom:feed 要素のメタデータを格納する。</p>
<h4><a name="l37"> </a>atom:summary 要素</h4>
<p>要約情報。</p>

<p>Text コンストラクト。</p>
    </div>
  </div>
</div>
<div>
  <h2><a name="l38"> </a>References</h2>
  <div>
    <div>
      <ul>

<li><a href="http://www.ietf.org/rfc/rfc4287">http://www.ietf.org/rfc/rfc4287</a></li>
<li><a href="http://www.futomi.com/lecture/japanese/rfc4287.html">http://www.futomi.com/lecture/japanese/rfc4287.html</a></li>
<li><a href="http://www.mdn.co.jp/index.php?option=com_content&amp;task=view&amp;id=752&amp;Itemid=54">http://www.mdn.co.jp/index.php?option=com_content&amp;task=view&amp;id=752&amp;Itemid=54</a></li>
</ul>
    </div>
  </div>
</div>
</div>