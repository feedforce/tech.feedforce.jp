---
title: ruby-gettext
date: 2007-05-09 10:12 JST
authors: ozawa
tags: ruby, resume, 
---
GNU gettextとはメッセージの国際化のためのCライブラリと各種コマンドのセット。

Ruby-GetText-PackageはそのRuby版。gettextのrubyバインディングではなく、再実装。

<dl>
<dt>URL</dt>
<dd><a href="http://www.yotabanana.com/hiki/ja/ruby-gettext.html" class="external">http://www.yotabanana.com/hiki/ja/ruby-gettext.html</a></dd>
<dt>作者</dt>
<dd>Masao Mutoh &lt;<a href="mailto:mutoh@highway.ne.jp&gt;" class="external">mailto:mutoh@highway.ne.jp&gt;</a>
</dd>

</dl>

<!--more-->

## 基礎知識

GNU gettextとはメッセージの国際化のためのCライブラリと各種コマンドのセット。

Ruby-GetText-PackageはそのRuby版。gettextのrubyバインディングではなく、再実装。

<dl>
<dt>URL</dt>
<dd><a href="http://www.yotabanana.com/hiki/ja/ruby-gettext.html" class="external">http://www.yotabanana.com/hiki/ja/ruby-gettext.html</a></dd>
<dt>作者</dt>
<dd>Masao Mutoh &lt;<a href="mailto:mutoh@highway.ne.jp&gt;" class="external">mailto:mutoh@highway.ne.jp&gt;</a>
</dd>

</dl>

インストールは

```
# gem install gettext
```

あるいは [http://rubyforge.org/frs/?group\_id=855](http://rubyforge.org/frs/?group_id=855) からダウンロード。

最新は1.9.0だが、Rails 1.1.6の場合はgettext 1.8.0でないとうまく動かない模様。

## 使用(生成)されるファイル

<dl>
<dt>POTファイル</dt>
<dd>POファイルのひな形となるファイル。(PO Template)</dd>
<dt>POファイル</dt>
<dd>キーと翻訳メッセージのペアを定義するファイル。(Portable Object)</dd>
<dt>MOファイル</dt>
<dd>POファイルをバイナリ化したもの。(Machine Object)</dd>

</dl>

ソースコード中に指定されたキーに対応する翻訳メッセージをMOファイルから抽出してキーを置き換えるというのが基本動作。

## Railsアプリケーションのgettext対応手順

### config/environment.rb

```
$KCODE = 'u' #Rails 1.2未満の場合
require 'gettext/rails'
```

### app/controllers/application.rb

```
class ApplicationController
	init_gettext 'myapp'
end
```

あとは、翻訳対象となるメッセージを

```
render :text => _('Not Found.')
```

や

```
<%= _('Welcome!') %>
```

のように \_ メソッドで囲む。

テーブル(モデル)名、カラム名もデフォルトで翻訳対象となる。(変更可)

## メッセージの翻訳

### 対象文字列の抽出

```
$ rake updatepo
```

updatepoタスクは以下のように定義する。

```
task :updatepo => :environment do
	require 'gettext/utils'
	files = Dir['{app,lib}/**/*.{rb,rhtml}']
	GetText.update_pofiles(PACKAGE, files, VERSION)
end
```

POTファイルが生成される。生成の際、DB接続を行うので、必要な設定・初期化を行っておくこと。

po/myapp.potには、いくつかのヘッダ行につづいて、

```
# 出現ソース位置
msgid "Welcome!"
msgstr ""
```

のような、翻訳対象キー文字列と空文字列のペアが並ぶ。

前回の処理以降
- 追加された文字列は、抽出される。
- 変更された文字列は、キーが差し替えられる。
- 削除された文字列は、コメントになってファイル末尾に移動する。

### 翻訳

POTファイルからPOファイルを生成する。

```
$ mkdir -p po/ja
$ msginit -i po/myapp.pot -o po/ja/myapp.po -l ja
```

単にPOTファイルをコピーしてもよいが、上のコマンド(GNU gettextに含まれる)を使うと、一部のメタ情報に適切な初期値が入る。

msgstrの空欄に翻訳されたメッセージを書き込む。

コメントに fuzzy と付けられたエントリーは他に見かけが似ているために間違っている可能性がある箇所を指摘している。 fuzzy コメントがついたエントリーが残っているとMOファイルの生成は行えない。 適宜修正するか、問題がなければ fuzzy コメント自体を削除すればよい。

### MOに変換

```
$ rake makemo
```

makemoタスクは以下のように定義する。

```
task :makemo do
	require 'gettext/utils'
	GetText.create_mofiles(true, 'po', 'locale')
end
```

実際に翻訳に利用するバイナリデータは　locale/ja/LC\_MESSAGES/myapp.mo として生成される。

## デモ

ttyrec/ttyplayによるサンプルセッション。(約10分)

```
$ telnet 192.168.1.18 12345
```

黒地に白推奨。

## 言語の選択

優先度の低いほうから

1. HTTPヘッダのAccept-Language

2. クッキーに保持された lang という値

3. QUERY\_STRINGの lang というパラメータの値

4. GetText.locale=で指定した言語

たとえば、ブラウザが

```
Accept-Language: ja, en
```

と送ってもURLが

```
...?lang=en
```

なら日本語ページではなく英語ページになる。

## 可変部を含む文字列の翻訳

```
"Hello #{h(user.name)}!"
```

を翻訳する場合に #{...} を使うと、抽出時(POT作成時)にも評価されてしまうため、 正しく抽出されない。

以下のようにする。
- 翻訳対象文字列自身は '' を使った固定文字列とする。
- #{...}は外に出してsprintf(あるいはString#%)に置き換える。

すなわち

```
sprintf(_('Hello %s!'), h(user.name))
```

または

```
_('Hello %s!') % h(user.name)
```

## 語順の違いへの対応

たとえば

```
_('Wrong value "%s" specified in field "%s".') % [h(value), h(field)]
```

という英語のメッセージに対応する日本語翻訳データを素直に作ると

```
msgid "Wrong value ?"%s?" specified in ?"%s?"."
msgstr "フィールド?"%s?"に誤った値?"%s?"が指定されました。"
```

のようになるが、語順が違うのでこれでは不十分。

この場合はprintf書式の拡張形式を使い、

```
msgstr "フィールド?"%2$s?"に誤った値?"%1$s?"が指定されました。"
```

と書くと、%2$sには第2引数が、%1$sには第1引数が適用される。

Ruby-GetTextでは String#%にArrayだけでなくHashを与えることができるため、別法として、

```
_('Wrong value "%{value}" specified in field "%{field}".') %
	{ :value => h(value), :field => h(field) }
```

と書いておく方法もある。この場合は語順に影響されることはなく、またプレースホルダに意味のある名前を使うことができるので、翻訳がしやすくなる。

## 複数形への対処

日本語だけを使っていると意識する必要はないが、数に従ってメッセージを変える必要のある言語がある。 そのような言語に対応するため、数によって変化する可能性があるメッセージには、\_ メソッドの代わりに n\_ メソッドを使う。

```
<%= n_('%d file was uploaded.', '%d files were uploaded.', count) % count %>
```

2回出現する数値のうち、1つめはn\_ の引数で、2つめは得られたメッセージ書式に実際に埋め込まれる値。

翻訳部分は

```
n_(msgid, msgid_plural, n)
```

という形式。

msgidは通常どおり翻訳先を探すためのキーとなる。

この種の翻訳では、msgstrは複数(0から数える)あり、nの値はPOファイル中のPlural-formsの式に渡され、これによってどの形式を使うかが決まる。 キーに対応するmsgstrが見つからない場合は、nが1ならmsgidが、nが1でないならmsgid\_pluralがそのまま使われる。

### 英語の場合

```
"Plural-Forms: nplurals=2; plural=(n != 1);"
msgid '%d file was uploaded.'
msgid_plural '%d file were uploaded.'
msgstr[0] '%d file was uploaded.'
msgstr[1] '%d files were uploaded.'
```

nが1のときのみ0番を使い、それ以外は1番を使う。

### 日本語の場合

```
"Plural-Forms: nplurals=1; plural=0;"
msgid '%d file was uploaded.'
msgid_plural '%d file were uploaded.'
msgstr[0] '%d個のファイルがアップロードされました。'
```

常に同じメッセージを使う。

### おまけ

#### フランス語の場合

```
"Plural-Forms: nplurals=2; plural=n>1;"
```

英語とほぼ同じだが、ゼロのときは単数と同じ表記を使う。

#### ロシア語の場合

```
"Plural-Forms: nplurals=3; ?
plural=(n%10==1 && n%100!=11 ? 0 : ?
	n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2);"
```

下一桁が1のとき(下二桁が11のときを除く)、下一桁が2〜4(下二桁が12〜14のときを除く)、それ以外(下二桁が11〜14のときを含む)。
- 1,21,31,...
- 2-4,22-24,32-34,...
- 5-20,25-30,35-40,...

#### スロベニア語の場合

```
"Plural-Forms: nplurals=4; ?
plural=n%100==1 ? 0 : n%100==2 ? 1 : n%100==3 || n%100==4 ? 2 : 3;"
```

下二桁が01のとき、下二桁が02のとき、下二桁が03または04のとき、それ以外。
- 1,101,201,...
- 2,102,202,...
- 3-4,103-104,203-204,...
- 5-110,105-200,...

実際の国際化はメッセージを翻訳すれば済むわけではないのが難しいところ。
- 数値(小数点・桁区切り記号・負数の書式)
- 単位(金額・温度・距離)
- 日付(書式・祝日・時差・夏時間・暦法)
- 正書法(使用文字・方向・空白の扱い・句読点や記号類)
- その他の習慣(名前や住所の形式・整列順)

