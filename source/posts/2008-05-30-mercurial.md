---
title: Mercurial はじめの一歩
date: 2008-05-30 16:11:35
authors: ozawa
tags: resume, 
---
弊社ではソースコードの管理に<a href="http://subversion.tigris.org/">Subversion</a>を使用していますが、個人的に興味があるので、分散バージョン管理システムの一つである<a href="http://www.selenic.com/mercurial/wiki/">Mercurial</a>を触ってみました。

<!--more-->
<h2>Mercurialとは</h2>
<ul>
	<li>mercurial [マ<strong>キュ</strong>リアル] 機敏な、快活な、水銀(mercury/記号Hg)の→コマンド名 hg</li>
	<li>分散バージョン管理システムのひとつ</li>
	<li>ほぼ<a href="http://www.python.org/">Python</a>で実装(diffのみC)</li>
	<li>バージョン1.0(2008/3/24) バージョン1.0.1(2008/05/22)</li>
	<li>フロントエンド <a href="http://tortoisehg.sourceforge.net/">TortoiseHg</a>(Windows) / mercurial.el(Emacs) / <a href="http://macromates.com/svn/Bundles/trunk/Bundles/Mercurial.tmbundle/">Mercurial bundle</a>(<a href="http://macromates.com/">TextMate</a>)など</li>
</ul>
<h2>分散バージョン管理システムとは</h2>
<ul>
	<li>バージョン管理システムのうち、中央リポジトリを持たない (特定のリポジトリをそう看倣すのはOK)もの</li>
	<li>リポジトリを複製する。</li>
	<li>複製したリポジトリに対して自分で行った修正点を格納していく。</li>
	<li>他のリポジトリと変更点を共有したいときは、変更点を反映するコマンドを使う。</li>
	<li>他の実装 <a href="http://svk.bestpractical.com/view/HomePage">svk</a> / <a href="http://git.or.cz/">git</a> / <a href="http://darcs.net/">darcs</a> / <a href="http://bazaar-vcs.org/">bazaar</a> など</li>
</ul>
<h2>使ってみる</h2>
<h3>リポジトリの作成</h3>
試しに<a href="http://www.rubyonrails.org/">Rails</a>アプリケーションを作成して、リポジトリに格納してみます。
<pre><code>$ rails -q hgdemo (管理対象作成)
$ cd hgdemo
$ ls -a
./  README   app/     db/   lib/  public/ test/ vendor/
../ Rakefile    config/ doc/ log/ script/ tmp/
$ hg init (リポジトリ初期化)
$ ls -a
./  .hg/       Rakefile config/ doc/ log/     script/ tmp/
../ README app/      db/      lib/   public/ test/    vendor/</code></pre>
管理用ディレクトリ .hg/ が出来ました。
<pre><code>$ hg add (ファイルを追加)
adding README
adding Rakefile
adding app/controllers/application.rb
:
:
adding script/runner
adding script/server
adding test/test_helper.rb</code></pre>
引数なしのaddでカレントディレクトリ以下の全てのファイルが追加対象になりました。
<pre><code>$ hg commit (コミット)</code></pre>
コミットログの入力を求められます。

この状態で、このディレクトリはレポジトリになっています。
<a href="http://www.nongnu.org/cvs/">CVS</a>やSubversionでは、どこかよそに作ったリポジトリから作業用にコードを取り出してきますが、Mercurialでは「作業用コード = リポジトリ」です。(正確には .hg/ 以下に格納される)
<h3>リポジトリの複製</h3>
分散バージョン管理システムでは、作業コピーを作る代わりに、リポジトリ自体を複製します。複製されたリポジトリに自身による変更を行った後で、他のリポジトリと変更点のやりとりを行うことで開発を進めます。

とりあえずローカルで別のディレクトリに複製をしてみます。
<pre><code>$ hg clone hgdemo hgdemo-clone</code></pre>
sshやhttpを使ってネットワーク越しに複製することも出来ます。
<h3>変更点の伝搬</h3>
hgdemo-clone上で何か変更を行ってみます。
<pre><code>$ ruby script/generate model User
$ hg add
$ hg commit -m 'Add user model'</code></pre>
リポジトリhgdemo-cloneにコミットが行われました。

これを複製元のhgdemoに反映するには、
<pre><code>$ hg push</code></pre>
を行います。

複製元リポジトリを読み込めるが書き込めない場合などは
<pre><code>$ hg export &gt; changes.diff</code></pre>
として変更点をパッチファイルとして取り出し、メールで複製元の管理者に送るなどします。

他の人が同じように各自が複製したリポジトリから変更を反映している場合、それを手元に持ってくるには
<pre><code>$ hg pull</code></pre>
とします。
<h2>利用例</h2>
普通に共同開発作業に使えるのは当然なのですが、分散バージョン管理システムならではの利用方法を考えてみました。

以下の例は、Mercurialに限らず、他の分散バージョン管理システムでも実施可能なはずです。
<h3>ネットワークが途切れた状態での開発</h3>
外出先などでもコミットはローカルのリポジトリに対して行われるので、自由にコミットし、ネットワーク接続が確保できたらpullを行う。

これは分散バージョン管理システムを使うとき最初に紹介されることが多いケースです。
<h3>外部リポジトリの私的複製</h3>
<ul>
	<li>一般公開されているリポジトリXがある。</li>
	<li>私的な修正(改造)がしたい。</li>
	<li>でも、コミットはできない。</li>
</ul>
→XをチェックアウトしてそのままMercurialリポジトリ化する。

XがMercurialで公開されていれば、普通に hg cloneを行えばよいです。 そうでない、たとえばSubversionで公開されている場合、svn coでチェックアウトしたあと、 ローカルで hg init を行い、ローカルでは Mercurialリポジトリとして管理します。

その後、
<ul>
	<li>ローカルで行った変更点はMercurialでMercurialリポジトリへコミット。</li>
	<li>オリジナルXの変更はsvn upでローカルコードを更新したあと、やはりMercurialにコミット。</li>
</ul>
という運用を行います。

もちろん、相手がSubversionならsvkを使うほうが自然でしょう。
<h3>実験ブランチ</h3>
<ul>
	<li>実験的なコードを作りたい。</li>
	<li>ブランチとして作ると、あとで不要になってもリポジトリのツリー内に残ってしまう。</li>
</ul>
→実験用リポジトリとして複製を行う。
<ul>
	<li>複製はpushを行わない限り複製元には反映されないので、いくつでも、気兼ねなく作れます。</li>
	<li>いらなくなったら単に削除すればOK。</li>
</ul>
<h3>設定ファイルなど</h3>
<ul>
	<li>さまざまなホストで参照される設定ファイル(個人のドットファイルなども含む)を管理したい。</li>
	<li>各ホストごとに異なる設定箇所もある。</li>
</ul>
→ホストごとにリポジトリを複製する。
<ul>
	<li>ホストごとに異なる部分は複製先にコミットするだけ。</li>
	<li>pushは行わない。共有したい変更箇所は明示的にexport &amp; importする。(changesetを選択的にpushする方法があれば、どなたか教えてください)</li>
</ul>
<h2>おわりに</h2>
Mercurialの簡単な使い方と分散バージョン管理システムならではの利用方法を紹介してみました。