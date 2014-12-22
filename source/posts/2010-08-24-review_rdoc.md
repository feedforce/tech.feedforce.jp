---
title: おさらいRDoc
date: 2010-08-24 18:15 JST
authors: r-suzuki
tags: ruby, resume, 
---
Rubyエンジニアのみなさん、RDoc書いてますか？「人が書いたRDocは読むけど、自分ではあまり書かない...」という方もいらっしゃるかもしれません。そこで今回はRDocを書くための要点について整理してみました。

<!--more-->  

## RDocの特徴

RDocとは、ソースコードを解析してHTML形式などのドキュメントを出力するツールです。Rubyはもちろん、Cで書かれたライブラリのコードも解析の対象となります。

ドキュメントはモジュール、クラス、メソッドといったプログラムの構造や、コメント部分から生成されます。独立した文書ではなくソースコードから生成されるので、メンテナンスしやすいと言えるでしょう。

## インストール

ruby1.8系と一緒にインストールされるrdocはバージョンが古いので、gemで新しいものをインストールしておくとよいでしょう。今回はruby1.8.7とrdoc2.3.0を使用します。（最新版は2.5.11ですが、後述のhannaテンプレートを利用するため2.3.0を選んでいます）

```
$ sudo gem install rdoc -v 2.3.0
$ rdoc --version
rdoc 2.3.0
```

## ドキュメントの生成

ドキュメントの生成はrdocコマンドで行います。ドキュメントは指定のファイル、または指定ディレクトリ以下のファイルから生成され、docディレクトリ以下に出力されます。（出力先の指定は-oオプションで可能）ためしに既存のソースコードから生成してみましょう。

```
$ rdoc [オプション] [ファイルまたはディレクトリのパス...]
```

### 主なオプション

rdocコマンドの主なオプションを以下に紹介します。詳細は rdoc --help で確認してください。

- -c, --charset : 出力文字コードの指定
- -U, --force-update : 変更されたソースがなくても生成しなおす
- -f, --format : フォーマット（HTML, riなど）の指定
- -S, --inline-source : ソースコード表示をインラインにする
- -N, --line-numbers : ソースコード表示に行番号を表示
- -m, --main : 先頭ページの指定
- -o, --op : 出力先ディレクトリの指定
- -T, --template : HTMLテンプレートの指定（後述）

### RDOCOPT

例えば出力文字コードのように、毎回指定するのが面倒なオプションがあります。こういったオプションは環境変数RDOCOPTに設定しておくことで、コマンド入力時の指定を省略することができます。ご自分の環境に合わせて ~/.zshrc などに設定を追加してみましょう。

```
# ~/.zshrcに以下を記述することで-cオプションの指定を省略できる（zshの場合）
export RDOCOPT="-c UTF8"
```

## 書き方

rdocはモジュールやクラス、メソッドなどの直前に書かれたコメント部分をそれらの説明としてドキュメント化します。

```
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

```

例えば上記のソースコードからRDocを生成すると、出力結果は以下のようになります。（htmlフォーマットを指定した場合）

[![RDoc出力例](/images/2010/08/rdoc_sample.thumbnail.png)](/images/2010/08/rdoc_sample.png "RDoc出力例")

### マークアップ

決められたルールに従ったコメントを記述することで、出力結果に書式を設定することができます。以下に主な書式を紹介します。

#### 見出し

```
=見出し1
==見出し2
===見出し3
...
```

![書式: 見出し](/images/2010/08/rdoc_header.png)

#### リスト

```
* リスト1
* リスト2
  * ネストはインデントを下げる
1. 数字リスト
2. 数字リスト
3. 数字リスト
```

![書式: リスト](/images/2010/08/rdoc_list1.png)

#### ラベル付きリスト

```
[list1] リスト1
[list2] リスト2
list1:: リスト1
list2:: リスト2
```

![書式: ラベル付きリスト](/images/2010/08/rdoc_list2.png)

#### 文字スタイル

```
*bold*
_italic_
+typewriter+
```

アルファベット、アンダースコア以外を含む場合は以下を使用します

```
<b>太字</b>
<em>イタリック</em>
<tt>タイプライター体</tt>
```

![書式: 文字スタイル](/images/2010/08/rdoc_style.png)

#### リンク

URLとみなされる文字列はリンクになります。リンク文字列を指定することも可能です。画像のURLはドキュメントに挿入されます。

```
http://tech.feedforce.jp
{FFTT}[http://tech.feedforce.jp]
http://www.feedforce.jp/recruit/img/feature/fftt.gif
```

![書式: リンク](/images/2010/08/rdoc_link.png)

### ディレクティブ

ドキュメントの生成について細かな指定を行うディレクティブが用意されています。

#### :nodoc:

指定の要素をドキュメントに含めないよう指定することができます。「:nodoc:」と指定した場合と「:nodoc: all」と指定した場合でドキュメント対象が異なります。

```
# このモジュール自体はドキュメント化されない
module HiddenModule1 # :nodoc:
  # このクラスはドキュメント化される
  class Visible
  end
end

module HiddenModule2 # :nodoc: all
  # このクラスはドキュメント化されない
  class Invisible
  end
end
```

#### :yield:

yield呼び出しを含むメソッドは、そのパラメータ名が表示されます。:yield:ディレクティブを指定すると、その表示パラメータ名を変更できます。

![ディレクティブ: yield](/images/2010/08/rdoc_yield.png)

その他のマークアップやディレクティブについては [RDocのドキュメント](http://rdoc.rubyforge.org/RDoc.html)を参照してください。

## テンプレート

組み込みでDarkfishやhtmlといったテンプレート（フォーマット）が用意されていますが、その他に公開されているテンプレートを利用することもできます。試しに [hanna](http://github.com/mislav/hanna)というテンプレートを利用してみましょう。

### インストールとドキュメントの生成

hannaテンプレートはgemで提供されています。

```
$ sudo gem install hanna
```

hannaテンプレートを使ったドキュメント生成は以下のように実行します。

```
rdoc -f html -S -T hanna [ファイルまたはディレクトリのパス...]
# または
hanna [オプション] [ファイルまたはディレクトリのパス...]
```

先ほど生成したドキュメントをhannaテンプレートで生成すると以下のようになります。Ajaxによるメソッドの検索が可能です。

[![hannaテンプレート](/images/2010/08/rdoc_hanna.thumbnail.png)](/images/2010/08/rdoc_hanna.png "hannaテンプレート")

### その他のテンプレート

- [Allison](http://blog.evanweaver.com/files/doc/fauna/allison/files/README.html)
- [sdoc](http://github.com/voloko/sdoc)

## Rakeタスクの定義

環境変数RDOCOPTでrdocコマンド共通のオプションは指定できますが、チームメンバー間での共有やプロジェクト別の指定には対応できません。そこでRakeタスクを定義して、ドキュメント生成作業を定型化してみましょう。例えば以下のようにRakefileを記述することで、ドキュメント生成タスク:rdocを定義できます。

```
require 'rake/rdoctask'
gem 'rdoc', '2.3.0' # gemでインストールされたrdocを使う場合に必要
require 'rdoc'

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.options
```

なお弊社内のプロジェクトでは [CruiseControl.rb](http://cruisecontrolrb.thoughtworks.com/)でのビルドの際にRDocを生成し、ビルドサーバからいつでも参照できるようにしています。

## おわりに

以上のように、RDocは比較的少ない労力で参照しやすいドキュメントを生成することができます。特にチーム開発をされている場合は、円滑なコミュニケーションのために役立ててみてはいかがでしょうか。

### 参考

- [rdoc Documentation](http://rdoc.rubyforge.org/)
- [『Rubyベストプラクティス』](http://www.amazon.co.jp/gp/product/4873114454?ie=UTF8&tag=htmlmmg-22&linkCode=as2&camp=247&creative=7399&creativeASIN=4873114454)![](http://www.assoc-amazon.jp/e/ir?t=htmlmmg-22&l=as2&o=9&a=4873114454)
- [『プログラミングRuby 1.9 －言語編－』](http://www.amazon.co.jp/gp/product/4274068099?ie=UTF8&tag=htmlmmg-22&linkCode=as2&camp=247&creative=7399&creativeASIN=4274068099)![](http://www.assoc-amazon.jp/e/ir?t=htmlmmg-22&l=as2&o=9&a=4274068099)

