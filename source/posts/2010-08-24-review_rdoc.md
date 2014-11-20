---
title: おさらいRDoc
date: 2010-08-24 18:15 JST
authors: r-suzuki
tags: ruby, resume, 
---
<p>Rubyエンジニアのみなさん、RDoc書いてますか？「人が書いたRDocは読むけど、自分ではあまり書かない...」という方もいらっしゃるかもしれません。そこで今回はRDocを書くための要点について整理してみました。</p>
<!--more-->
<h2>RDocの特徴</h2>
<p>RDocとは、ソースコードを解析してHTML形式などのドキュメントを出力するツールです。Rubyはもちろん、Cで書かれたライブラリのコードも解析の対象となります。</p>
<p>ドキュメントはモジュール、クラス、メソッドといったプログラムの構造や、コメント部分から生成されます。独立した文書ではなくソースコードから生成されるので、メンテナンスしやすいと言えるでしょう。</p>

<h2>インストール</h2>
<p>ruby1.8系と一緒にインストールされるrdocはバージョンが古いので、gemで新しいものをインストールしておくとよいでしょう。今回はruby1.8.7とrdoc2.3.0を使用します。（最新版は2.5.11ですが、後述のhannaテンプレートを利用するため2.3.0を選んでいます）</p>
<pre><code>
$ sudo gem install rdoc -v 2.3.0
$ rdoc --version
rdoc 2.3.0
</code></pre>

<h2>ドキュメントの生成</h2>
<p>ドキュメントの生成はrdocコマンドで行います。ドキュメントは指定のファイル、または指定ディレクトリ以下のファイルから生成され、docディレクトリ以下に出力されます。（出力先の指定は-oオプションで可能）ためしに既存のソースコードから生成してみましょう。</p>
<pre><code>
$ rdoc [オプション] [ファイルまたはディレクトリのパス...]
</code></pre>
<h3>主なオプション</h3>
<p>rdocコマンドの主なオプションを以下に紹介します。詳細は rdoc --help で確認してください。</p>
<ul>
  <li>-c, --charset : 出力文字コードの指定</li>
  <li>-U, --force-update : 変更されたソースがなくても生成しなおす</li>
  <li>-f, --format : フォーマット（HTML, riなど）の指定</li>
  <li>-S, --inline-source : ソースコード表示をインラインにする</li>
  <li>-N, --line-numbers : ソースコード表示に行番号を表示</li>
  <li>-m, --main : 先頭ページの指定</li>
  <li>-o, --op : 出力先ディレクトリの指定</li>
  <li>-T, --template : HTMLテンプレートの指定（後述）</li>
</ul>

<h3>RDOCOPT</h3>
<p>例えば出力文字コードのように、毎回指定するのが面倒なオプションがあります。こういったオプションは環境変数RDOCOPTに設定しておくことで、コマンド入力時の指定を省略することができます。ご自分の環境に合わせて ~/.zshrc などに設定を追加してみましょう。</p>
<pre><code>
# ~/.zshrcに以下を記述することで-cオプションの指定を省略できる（zshの場合）
export RDOCOPT="-c UTF8"
</code></pre>

<h2>書き方</h2>
<p>rdocはモジュールやクラス、メソッドなどの直前に書かれたコメント部分をそれらの説明としてドキュメント化します。</p>
<pre><code>
=begin rdoc
先頭のコメント部分はファイルの説明として扱われる
=end

# クラスの説明
class Sample
  # 定数の例
  CONST_SAMPLE = 'sample'

  # 属性(リーダー)
  attr_reader :reader
  # 属性(ライター)
  attr_writer :writer
  # 属性(アクセッサ)
  attr_accessor :accessor

  # メソッドの説明
  def sample_method
    # ...
  end
end

</code></pre>
<p>例えば上記のソースコードからRDocを生成すると、出力結果は以下のようになります。（htmlフォーマットを指定した場合）</p>
<a href='http://tech.feedforce.jp/wp-content/uploads/2010/08/rdoc_sample.png' title='RDoc出力例'><img src='http://tech.feedforce.jp/wp-content/uploads/2010/08/rdoc_sample.thumbnail.png' alt='RDoc出力例' /></a>

<h3>マークアップ</h3>
<p>決められたルールに従ったコメントを記述することで、出力結果に書式を設定することができます。以下に主な書式を紹介します。</p>
<h4>見出し</h4>
<pre><code>
=見出し1
==見出し2
===見出し3
...
</code></pre>
<img src='http://tech.feedforce.jp/wp-content/uploads/2010/08/rdoc_header.png' alt='書式: 見出し' />
<h4>リスト</h4>
<pre><code>
* リスト1
* リスト2
  * ネストはインデントを下げる
1. 数字リスト
2. 数字リスト
3. 数字リスト
</code></pre>
<img src='http://tech.feedforce.jp/wp-content/uploads/2010/08/rdoc_list1.png' alt='書式: リスト' />
<h4>ラベル付きリスト</h4>
<pre><code>
[list1] リスト1
[list2] リスト2
list1:: リスト1
list2:: リスト2
</code></pre>
<img src='http://tech.feedforce.jp/wp-content/uploads/2010/08/rdoc_list2.png' alt='書式: ラベル付きリスト' />
<h4>文字スタイル</h4>
<pre><code>
*bold*
_italic_
+typewriter+
</code></pre>
<p>アルファベット、アンダースコア以外を含む場合は以下を使用します</p>
<pre><code>
&lt;b&gt;太字&lt;/b&gt;
&lt;em&gt;イタリック&lt;/em&gt;
&lt;tt&gt;タイプライター体&lt;/tt&gt;
</code></pre>
<img src='http://tech.feedforce.jp/wp-content/uploads/2010/08/rdoc_style.png' alt='書式: 文字スタイル' />
<h4>リンク</h4>
<p>URLとみなされる文字列はリンクになります。リンク文字列を指定することも可能です。画像のURLはドキュメントに挿入されます。</p>
<pre><code>
http://tech.feedforce.jp
{FFTT}[http://tech.feedforce.jp]
http://www.feedforce.jp/recruit/img/feature/fftt.gif
</code></pre>
<img src='http://tech.feedforce.jp/wp-content/uploads/2010/08/rdoc_link.png' alt='書式: リンク' />

<h3>ディレクティブ</h3>
<p>ドキュメントの生成について細かな指定を行うディレクティブが用意されています。</p>
<h4>:nodoc:</h4>
<p>指定の要素をドキュメントに含めないよう指定することができます。「:nodoc:」と指定した場合と「:nodoc: all」と指定した場合でドキュメント対象が異なります。</p>
<pre><code>
# このモジュール自体はドキュメント化されない
module HiddenModule1  # :nodoc:
  # このクラスはドキュメント化される
  class Visible
  end
end

module HiddenModule2  # :nodoc: all
  # このクラスはドキュメント化されない
  class Invisible
  end
end
</code></pre>
<h4>:yield:</h4>
<p>yield呼び出しを含むメソッドは、そのパラメータ名が表示されます。:yield:ディレクティブを指定すると、その表示パラメータ名を変更できます。</p>
<img src='http://tech.feedforce.jp/wp-content/uploads/2010/08/rdoc_yield.png' alt='ディレクティブ: yield' />
<p>その他のマークアップやディレクティブについては<a href="http://rdoc.rubyforge.org/RDoc.html">RDocのドキュメント</a>を参照してください。</p>

<h2>テンプレート</h2>
<p>組み込みでDarkfishやhtmlといったテンプレート（フォーマット）が用意されていますが、その他に公開されているテンプレートを利用することもできます。試しに<a href="http://github.com/mislav/hanna">hanna</a>というテンプレートを利用してみましょう。</p>
<h3>インストールとドキュメントの生成</h3>
<p>hannaテンプレートはgemで提供されています。</p>
<pre><code>
$ sudo gem install hanna
</code></pre>
<p>hannaテンプレートを使ったドキュメント生成は以下のように実行します。</p>
<pre><code>
rdoc -f html -S -T hanna [ファイルまたはディレクトリのパス...]
# または
hanna [オプション] [ファイルまたはディレクトリのパス...]
</code></pre>
<p>先ほど生成したドキュメントをhannaテンプレートで生成すると以下のようになります。Ajaxによるメソッドの検索が可能です。</p>
<a href='http://tech.feedforce.jp/wp-content/uploads/2010/08/rdoc_hanna.png' title='hannaテンプレート'><img src='http://tech.feedforce.jp/wp-content/uploads/2010/08/rdoc_hanna.thumbnail.png' alt='hannaテンプレート' /></a>
<h3>その他のテンプレート</h3>
<ul>
  <li><a href="http://blog.evanweaver.com/files/doc/fauna/allison/files/README.html">Allison</a></li>
  <li><a href="http://github.com/voloko/sdoc">sdoc</a></li>
</ul>

<h2>Rakeタスクの定義</h2>
<p>環境変数RDOCOPTでrdocコマンド共通のオプションは指定できますが、チームメンバー間での共有やプロジェクト別の指定には対応できません。そこでRakeタスクを定義して、ドキュメント生成作業を定型化してみましょう。例えば以下のようにRakefileを記述することで、ドキュメント生成タスク:rdocを定義できます。</p>
<pre><code>
require 'rake/rdoctask'
gem 'rdoc', '2.3.0' # gemでインストールされたrdocを使う場合に必要
require 'rdoc'

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.options << '-f html' << '-S' << '-N' << '-c UTF8'
  rdoc.rdoc_files.include(%w[README lib])
  rdoc.rdoc_dir = 'doc/html'
  rdoc.main = 'README'
end
</code></pre>
<p>なお弊社内のプロジェクトでは<a href="http://cruisecontrolrb.thoughtworks.com/">CruiseControl.rb</a>でのビルドの際にRDocを生成し、ビルドサーバからいつでも参照できるようにしています。</p>

<h2>おわりに</h2>
<p>以上のように、RDocは比較的少ない労力で参照しやすいドキュメントを生成することができます。特にチーム開発をされている場合は、円滑なコミュニケーションのために役立ててみてはいかがでしょうか。</p>
<h3>参考</h3>
<ul>
  <li><a href="http://rdoc.rubyforge.org/">rdoc Documentation</a></li>
  <li><a href="http://www.amazon.co.jp/gp/product/4873114454?ie=UTF8&tag=htmlmmg-22&linkCode=as2&camp=247&creative=7399&creativeASIN=4873114454">『Rubyベストプラクティス』</a><img src="http://www.assoc-amazon.jp/e/ir?t=htmlmmg-22&l=as2&o=9&a=4873114454" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" /></li>
  <li><a href="http://www.amazon.co.jp/gp/product/4274068099?ie=UTF8&tag=htmlmmg-22&linkCode=as2&camp=247&creative=7399&creativeASIN=4274068099">『プログラミングRuby 1.9 －言語編－』</a><img src="http://www.assoc-amazon.jp/e/ir?t=htmlmmg-22&l=as2&o=9&a=4274068099" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
</li>
</ul>
