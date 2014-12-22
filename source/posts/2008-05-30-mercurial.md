---
title: Mercurial はじめの一歩
date: 2008-05-30 16:11 JST
authors: ozawa
tags: resume, 
---
弊社ではソースコードの管理に [Subversion](http://subversion.tigris.org/)を使用していますが、個人的に興味があるので、分散バージョン管理システムの一つである [Mercurial](http://www.selenic.com/mercurial/wiki/)を触ってみました。

<!--more-->

## Mercurialとは

- mercurial [マ **キュ** リアル] 機敏な、快活な、水銀(mercury/記号Hg)の→コマンド名 hg
- 分散バージョン管理システムのひとつ
- ほぼ [Python](http://www.python.org/)で実装(diffのみC)
- バージョン1.0(2008/3/24) バージョン1.0.1(2008/05/22)
- フロントエンド [TortoiseHg](http://tortoisehg.sourceforge.net/)(Windows) / mercurial.el(Emacs) / [Mercurial bundle](http://macromates.com/svn/Bundles/trunk/Bundles/Mercurial.tmbundle/)( [TextMate](http://macromates.com/))など

## 分散バージョン管理システムとは

- バージョン管理システムのうち、中央リポジトリを持たない (特定のリポジトリをそう看倣すのはOK)もの
- リポジトリを複製する。
- 複製したリポジトリに対して自分で行った修正点を格納していく。
- 他のリポジトリと変更点を共有したいときは、変更点を反映するコマンドを使う。
- 他の実装 [svk](http://svk.bestpractical.com/view/HomePage) / [git](http://git.or.cz/) / [darcs](http://darcs.net/) / [bazaar](http://bazaar-vcs.org/) など

## 使ってみる

### リポジトリの作成
試しに [Rails](http://www.rubyonrails.org/)アプリケーションを作成して、リポジトリに格納してみます。  

```
$ rails -q hgdemo (管理対象作成)
$ cd hgdemo
$ ls -a
./ README app/ db/ lib/ public/ test/ vendor/
../ Rakefile config/ doc/ log/ script/ tmp/
$ hg init (リポジトリ初期化)
$ ls -a
./ .hg/ Rakefile config/ doc/ log/ script/ tmp/
../ README app/ db/ lib/ public/ test/ vendor/
```
管理用ディレクトリ .hg/ が出来ました。  

```
$ hg add (ファイルを追加)
adding README
adding Rakefile
adding app/controllers/application.rb
:
:
adding script/runner
adding script/server
adding test/test_helper.rb
```
引数なしのaddでカレントディレクトリ以下の全てのファイルが追加対象になりました。  

```
$ hg commit (コミット)
```
コミットログの入力を求められます。

この状態で、このディレクトリはレポジトリになっています。  

 [CVS](http://www.nongnu.org/cvs/)やSubversionでは、どこかよそに作ったリポジトリから作業用にコードを取り出してきますが、Mercurialでは「作業用コード = リポジトリ」です。(正確には .hg/ 以下に格納される)  

### リポジトリの複製
分散バージョン管理システムでは、作業コピーを作る代わりに、リポジトリ自体を複製します。複製されたリポジトリに自身による変更を行った後で、他のリポジトリと変更点のやりとりを行うことで開発を進めます。

とりあえずローカルで別のディレクトリに複製をしてみます。  

```
$ hg clone hgdemo hgdemo-clone
```
sshやhttpを使ってネットワーク越しに複製することも出来ます。  

### 変更点の伝搬
hgdemo-clone上で何か変更を行ってみます。  

```
$ ruby script/generate model User
$ hg add
$ hg commit -m 'Add user model'
```
リポジトリhgdemo-cloneにコミットが行われました。

これを複製元のhgdemoに反映するには、  

```
$ hg push
```
を行います。

複製元リポジトリを読み込めるが書き込めない場合などは  

```
$ hg export > changes.diff
```
として変更点をパッチファイルとして取り出し、メールで複製元の管理者に送るなどします。

他の人が同じように各自が複製したリポジトリから変更を反映している場合、それを手元に持ってくるには  

```
$ hg pull
```
とします。  

## 利用例
普通に共同開発作業に使えるのは当然なのですが、分散バージョン管理システムならではの利用方法を考えてみました。

以下の例は、Mercurialに限らず、他の分散バージョン管理システムでも実施可能なはずです。  

### ネットワークが途切れた状態での開発
外出先などでもコミットはローカルのリポジトリに対して行われるので、自由にコミットし、ネットワーク接続が確保できたらpullを行う。

これは分散バージョン管理システムを使うとき最初に紹介されることが多いケースです。  

### 外部リポジトリの私的複製

- 一般公開されているリポジトリXがある。
- 私的な修正(改造)がしたい。
- でも、コミットはできない。

→XをチェックアウトしてそのままMercurialリポジトリ化する。

XがMercurialで公開されていれば、普通に hg cloneを行えばよいです。 そうでない、たとえばSubversionで公開されている場合、svn coでチェックアウトしたあと、 ローカルで hg init を行い、ローカルでは Mercurialリポジトリとして管理します。

その後、  

- ローカルで行った変更点はMercurialでMercurialリポジトリへコミット。
- オリジナルXの変更はsvn upでローカルコードを更新したあと、やはりMercurialにコミット。

という運用を行います。

もちろん、相手がSubversionならsvkを使うほうが自然でしょう。  

### 実験ブランチ

- 実験的なコードを作りたい。
- ブランチとして作ると、あとで不要になってもリポジトリのツリー内に残ってしまう。

→実験用リポジトリとして複製を行う。  

- 複製はpushを行わない限り複製元には反映されないので、いくつでも、気兼ねなく作れます。
- いらなくなったら単に削除すればOK。

### 設定ファイルなど

- さまざまなホストで参照される設定ファイル(個人のドットファイルなども含む)を管理したい。
- 各ホストごとに異なる設定箇所もある。

→ホストごとにリポジトリを複製する。  

- ホストごとに異なる部分は複製先にコミットするだけ。
- pushは行わない。共有したい変更箇所は明示的にexport & importする。(changesetを選択的にpushする方法があれば、どなたか教えてください)

## おわりに
Mercurialの簡単な使い方と分散バージョン管理システムならではの利用方法を紹介してみました。