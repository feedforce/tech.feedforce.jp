---
title: ruby-gettext
date: 2007-05-09 10:12:40
authors: ozawa
tags: ruby, resume, 
---
      <p>GNU gettextとはメッセージの国際化のためのCライブラリと各種コマンドのセット。</p>
<p>Ruby-GetText-PackageはそのRuby版。gettextのrubyバインディングではなく、再実装。</p>
<dl>
<dt>URL</dt><dd><a href="http://www.yotabanana.com/hiki/ja/ruby-gettext.html" class="external">http://www.yotabanana.com/hiki/ja/ruby-gettext.html</a></dd>
<dt>作者</dt><dd>Masao Mutoh &lt;<a href="mailto:mutoh@highway.ne.jp&gt;" class="external">mailto:mutoh@highway.ne.jp&gt;</a></dd>
</dl>
<!--more-->
  <div><div class="day">
  <h2><span class="date"><a name="l0"> </a></span><span class="title">基礎知識</span></h2>
  <div class="body">
    <div class="section">
      <p>GNU gettextとはメッセージの国際化のためのCライブラリと各種コマンドのセット。</p>
<p>Ruby-GetText-PackageはそのRuby版。gettextのrubyバインディングではなく、再実装。</p>
<dl>
<dt>URL</dt><dd><a href="http://www.yotabanana.com/hiki/ja/ruby-gettext.html" class="external">http://www.yotabanana.com/hiki/ja/ruby-gettext.html</a></dd>
<dt>作者</dt><dd>Masao Mutoh &lt;<a href="mailto:mutoh@highway.ne.jp&gt;" class="external">mailto:mutoh@highway.ne.jp&gt;</a></dd>
</dl>
<p>インストールは</p>
<pre><code># gem install gettext</code></pre>
<p>あるいは <a href="http://rubyforge.org/frs/?group_id=855" class="external">http://rubyforge.org/frs/?group_id=855</a> からダウンロード。</p>
<p>最新は1.9.0だが、Rails 1.1.6の場合はgettext 1.8.0でないとうまく動かない模様。</p>
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l1"> </a></span><span class="title">使用(生成)されるファイル</span></h2>
  <div class="body">
    <div class="section">
      <dl>
<dt>POTファイル</dt><dd>POファイルのひな形となるファイル。(PO Template)</dd>
<dt>POファイル</dt><dd>キーと翻訳メッセージのペアを定義するファイル。(Portable Object)</dd>
<dt>MOファイル</dt><dd>POファイルをバイナリ化したもの。(Machine Object)</dd>
</dl>
<p>ソースコード中に指定されたキーに対応する翻訳メッセージをMOファイルから抽出してキーを置き換えるというのが基本動作。</p>
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l2"> </a></span><span class="title">Railsアプリケーションのgettext対応手順</span></h2>
  <div class="body">
    <div class="section">
      <h3><a name="l3"><span class="sanchor"> </span></a>config/environment.rb</h3>
<pre><code>$KCODE = 'u' #Rails 1.2未満の場合
require 'gettext/rails'
</code></pre>
<h3><a name="l4"><span class="sanchor"> </span></a>app/controllers/application.rb</h3>
<pre><code>class ApplicationController
	init_gettext 'myapp'
end
</code></pre>
<p>あとは、翻訳対象となるメッセージを</p>
<pre><code>render :text =&gt; _('Not Found.')</code></pre>
<p>や</p>
<pre><code>&lt;%= _('Welcome!') %&gt;</code></pre>
<p>のように _ メソッドで囲む。</p>
<p>テーブル(モデル)名、カラム名もデフォルトで翻訳対象となる。(変更可)</p>
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l5"> </a></span><span class="title">メッセージの翻訳</span></h2>
  <div class="body">
    <div class="section">
      <h3><a name="l6"><span class="sanchor"> </span></a>対象文字列の抽出</h3>
<pre><code>$ rake updatepo</code></pre>
<p>updatepoタスクは以下のように定義する。</p>
<pre><code>task :updatepo =&gt; :environment do
	require 'gettext/utils'
	files = Dir['{app,lib}/**/*.{rb,rhtml}']
	GetText.update_pofiles(PACKAGE, files, VERSION)
end</code></pre>
<p>POTファイルが生成される。生成の際、DB接続を行うので、必要な設定・初期化を行っておくこと。</p>
<p>po/myapp.potには、いくつかのヘッダ行につづいて、</p>
<pre><code># 出現ソース位置
msgid "Welcome!"
msgstr ""</code></pre>
<p>のような、翻訳対象キー文字列と空文字列のペアが並ぶ。</p>
<p>前回の処理以降</p>
<ul>
<li>追加された文字列は、抽出される。</li>
<li>変更された文字列は、キーが差し替えられる。</li>
<li>削除された文字列は、コメントになってファイル末尾に移動する。</li>
</ul>
<h3><a name="l7"><span class="sanchor"> </span></a>翻訳</h3>
<p>POTファイルからPOファイルを生成する。</p>
<pre><code>$ mkdir -p po/ja
$ msginit -i po/myapp.pot -o po/ja/myapp.po -l ja</code></pre>
<p>単にPOTファイルをコピーしてもよいが、上のコマンド(GNU gettextに含まれる)を使うと、一部のメタ情報に適切な初期値が入る。</p>
<p>msgstrの空欄に翻訳されたメッセージを書き込む。</p>
<p>コメントに fuzzy と付けられたエントリーは他に見かけが似ているために間違っている可能性がある箇所を指摘している。
fuzzy コメントがついたエントリーが残っているとMOファイルの生成は行えない。
適宜修正するか、問題がなければ fuzzy コメント自体を削除すればよい。</p>
<h3><a name="l8"><span class="sanchor"> </span></a>MOに変換</h3>
<pre><code>$ rake makemo</code></pre>
<p>makemoタスクは以下のように定義する。</p>
<pre><code>task :makemo do
	require 'gettext/utils'
	GetText.create_mofiles(true, 'po', 'locale')
end</code></pre>
<p>実際に翻訳に利用するバイナリデータは　locale/ja/LC_MESSAGES/myapp.mo として生成される。</p>
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l9"> </a></span><span class="title">デモ</span></h2>
  <div class="body">
    <div class="section">
      <p>ttyrec/ttyplayによるサンプルセッション。(約10分)</p>
<pre><code>$ telnet 192.168.1.18 12345</code></pre>
<p>黒地に白推奨。</p>
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l10"> </a></span><span class="title">言語の選択</span></h2>
  <div class="body">
    <div class="section">
      <p>優先度の低いほうから</p>
<ol>
<li>HTTPヘッダのAccept-Language</li>
<li>クッキーに保持された lang という値</li>
<li>QUERY_STRINGの lang というパラメータの値</li>
<li>GetText.locale=で指定した言語</li>
</ol>
<p>たとえば、ブラウザが</p>
<pre><code>Accept-Language: ja, en</code></pre>
<p>と送ってもURLが</p>
<pre><code>...?lang=en</code></pre>
<p>なら日本語ページではなく英語ページになる。</p>
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l11"> </a></span><span class="title">可変部を含む文字列の翻訳</span></h2>
  <div class="body">
    <div class="section">
      <pre><code>"Hello #{h(user.name)}!"</code></pre>
<p>を翻訳する場合に #{...} を使うと、抽出時(POT作成時)にも評価されてしまうため、
正しく抽出されない。</p>
<p>以下のようにする。</p>
<ul>
<li>翻訳対象文字列自身は '' を使った固定文字列とする。</li>
<li>#{...}は外に出してsprintf(あるいはString#%)に置き換える。</li>
</ul>
<p>すなわち</p>
<pre><code>sprintf(_('Hello %s!'), h(user.name))</code></pre>
<p>または</p>
<pre><code>_('Hello %s!') % h(user.name)</code></pre>
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l12"> </a></span><span class="title">語順の違いへの対応</span></h2>
  <div class="body">
    <div class="section">
      <p>たとえば</p>
<pre><code>_('Wrong value "%s" specified in field "%s".') % [ h(value), h(field) ]</code></pre>
<p>という英語のメッセージに対応する日本語翻訳データを素直に作ると</p>
<pre><code>msgid "Wrong value ?"%s?" specified in ?"%s?"."
msgstr "フィールド?"%s?"に誤った値?"%s?"が指定されました。"</code></pre>
<p>のようになるが、語順が違うのでこれでは不十分。</p>
<p>この場合はprintf書式の拡張形式を使い、</p>
<pre><code>msgstr "フィールド?"%2$s?"に誤った値?"%1$s?"が指定されました。"</code></pre>
<p>と書くと、%2$sには第2引数が、%1$sには第1引数が適用される。</p>
<p>Ruby-GetTextでは String#%にArrayだけでなくHashを与えることができるため、別法として、</p>
<pre><code>_('Wrong value "%{value}" specified in field "%{field}".') %
	{ :value =&gt; h(value), :field =&gt; h(field) }
</code></pre>
<p>と書いておく方法もある。この場合は語順に影響されることはなく、またプレースホルダに意味のある名前を使うことができるので、翻訳がしやすくなる。</p>
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l13"> </a></span><span class="title">複数形への対処</span></h2>
  <div class="body">
    <div class="section">
      <p>日本語だけを使っていると意識する必要はないが、数に従ってメッセージを変える必要のある言語がある。
そのような言語に対応するため、数によって変化する可能性があるメッセージには、_ メソッドの代わりに n_ メソッドを使う。</p>
<pre><code>&lt;%= n_('%d file was uploaded.', '%d files were uploaded.', count) % count %&gt;</code></pre>
<p>2回出現する数値のうち、1つめはn_ の引数で、2つめは得られたメッセージ書式に実際に埋め込まれる値。</p>
<p>翻訳部分は</p>
<pre><code>n_(msgid, msgid_plural, n)</code></pre>
<p>という形式。</p>
<p>msgidは通常どおり翻訳先を探すためのキーとなる。</p>
<p>この種の翻訳では、msgstrは複数(0から数える)あり、nの値はPOファイル中のPlural-formsの式に渡され、これによってどの形式を使うかが決まる。
キーに対応するmsgstrが見つからない場合は、nが1ならmsgidが、nが1でないならmsgid_pluralがそのまま使われる。</p>
<h3><a name="l14"><span class="sanchor"> </span></a>英語の場合</h3>
<pre><code>"Plural-Forms: nplurals=2; plural=(n != 1);"
msgid '%d file was uploaded.'
msgid_plural '%d file were uploaded.'
msgstr[0] '%d file was uploaded.'
msgstr[1] '%d files were uploaded.'</code></pre>
<p>nが1のときのみ0番を使い、それ以外は1番を使う。</p>
<h3><a name="l15"><span class="sanchor"> </span></a>日本語の場合</h3>
<pre><code>"Plural-Forms: nplurals=1; plural=0;"
msgid '%d file was uploaded.'
msgid_plural '%d file were uploaded.'
msgstr[0] '%d個のファイルがアップロードされました。'</code></pre>
<p>常に同じメッセージを使う。</p>
<h3><a name="l16"><span class="sanchor"> </span></a>おまけ</h3>
<h4><a name="l17"> </a>フランス語の場合</h4>
<pre><code>"Plural-Forms: nplurals=2; plural=n&gt;1;"
</code></pre>
<p>英語とほぼ同じだが、ゼロのときは単数と同じ表記を使う。</p>
<h4><a name="l18"> </a>ロシア語の場合</h4>
<pre><code>"Plural-Forms: nplurals=3; ?
plural=(n%10==1 &amp;&amp; n%100!=11 ? 0 : ?
	n%10&gt;=2 &amp;&amp; n%10&lt;=4 &amp;&amp; (n%100&lt;10 || n%100&gt;=20) ? 1 : 2);"</code></pre>
<p>下一桁が1のとき(下二桁が11のときを除く)、下一桁が2〜4(下二桁が12〜14のときを除く)、それ以外(下二桁が11〜14のときを含む)。</p>
<ul>
<li>1,21,31,...</li>
<li>2-4,22-24,32-34,...</li>
<li>5-20,25-30,35-40,...</li>
</ul>
<h4><a name="l19"> </a>スロベニア語の場合</h4>
<pre><code>"Plural-Forms: nplurals=4; ?
plural=n%100==1 ? 0 : n%100==2 ? 1 : n%100==3 || n%100==4 ? 2 : 3;"</code></pre>
<p>下二桁が01のとき、下二桁が02のとき、下二桁が03または04のとき、それ以外。</p>
<ul>
<li>1,101,201,...</li>
<li>2,102,202,...</li>
<li>3-4,103-104,203-204,...</li>
<li>5-110,105-200,...</li>
</ul>
<p>実際の国際化はメッセージを翻訳すれば済むわけではないのが難しいところ。</p>
<ul>
<li>数値(小数点・桁区切り記号・負数の書式)</li>
<li>単位(金額・温度・距離)</li>
<li>日付(書式・祝日・時差・夏時間・暦法)</li>
<li>正書法(使用文字・方向・空白の扱い・句読点や記号類)</li>
<li>その他の習慣(名前や住所の形式・整列順)</li>
</ul>
    </div>
  </div>
</div>
</div>