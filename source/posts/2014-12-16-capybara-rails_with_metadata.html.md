---
title: Capybaraでドキュメント・メタデータが出力されていることを確認したい
date: 2014-12-16 17:27 JST
authors: tmd45
tags: ruby, test
---

どうも。毎晩エオルゼアに帰宅しては冒険者の遺留品集めに勤しんでおります tmd45 こと玉田です。

この記事は最近 capybara を使っていてちょっと困ったこととその解決法です。
手元の環境は `rspec 3.0.0`, `rspec-rails 3.0.2`, `capybara 2.4.1` です。

<!--more-->

なお、タイトルでティンときて結論だけ知りたいという方は、下の方にスクロールして『ドキュメント・メタデータの HTML タグを capybara で match させるには？』をさくっとご確認ください。

![capybara](http://upload.wikimedia.org/wikipedia/commons/thumb/6/69/Capybara_Izu_Shaboten_001.jpg/800px-Capybara_Izu_Shaboten_001.jpg)
[引用元: 柚子湯に入るカピバラ（伊豆シャボテン公園）](http://commons.wikimedia.org/wiki/File:Capybara_Izu_Shaboten_001.jpg)

## ドキュメント・メタデータの HTML タグが capybara で match できない

ドキュメント・メタデータ（メタデータ・コンテンツ）とは HTML 文章に関する情報のことを指し、例えば以下の様な HTML タグで記述します。`<head>` 要素にはこのメタデータの集まりが書かれています。

* `<title>` タイトル
* `<link>` リンク情報
* `<meta>` メタデータ（meta 要素）

ドキュメント・メタデータは、文章情報や別文章との関係などを定義するもので、ブラウザから見たときに「人に見えるコンテンツ」ではありません。

私が携わっている弊社のサービス『ソーシャルPLUS』では、ブラウザ側で動作する JavaScript が存在しなければきちんとサービス提供ができません。
そのため簡易的ではありますが、ある画面のテストで “生成した（JavaScript の）URL が link タグで出力されていること” をテストしたいと思いました。

### capybara でテストしてみよう

文字列で言うと、このようなものが出力されていると期待します：
（href 属性、rel 属性が必須属性です）

```
<link href="http://www.example.com/style.css" rel="stylesheet" />
```

これを Capybara::RSpecMatcher の `have_selector` で以下のように記述しました：

```rb
html = '<link href="http://www.example.com/style.css" rel="stylesheet" />'
url = 'http://www.example.com/style.css'

# Capybara::RSpecMatchers を使ったテスト
expect(html).to have_selector("link[href='#{url}'][rel='stylesheet']")
```

しかし、テストを実行してみると「この条件にマッチするセレクタはないよ」と怒られてしまいました：

```
Failure/Error: it { expect(html).to have_selector("link[href='#{url}'][rel='stylesheet']") }
       expected to find css "link[href='http://www.example.com/style.css'][rel='stylesheet']" but there were no matches. Also found "", which matched the selector but not all filters.
```

#### 補足：matcher は以下のように書いても同じ意味になります

```rb
# kind :css
expect(html).to have_selector(:css, "link[href='#{url}'][rel='stylesheet']")
expect(html).to have_css("link[href='#{url}'][rel='stylesheet']")
# kind :xpath
expect(html).to have_selector(:xpath, "//link[@href='#{url}'][@rel='stylesheet']")
expect(html).to have_xpath("//link[@href='#{url}'][@rel='stylesheet']")
```

### 他のタグはマッチするんだよね

ここで結構手間取っていて、「css セレクタだとメタデータの指定ってできないんだっけ？」とか「css セレクタや xpath セレクタの書き方を間違ったのかもしれない」といろいろ試行錯誤しました。
私は API ドキュメント・ラヴァー ではありますが  `have_selector` の項や、その部分だけのコードを見てもさっぱりわかりませんでした。結果から見れば、深堀りが足りなかっただけなのですが（あるいは実際のコードを追ったほうが早い）。

もっと簡単なコードで確認してみましょう。
ここでは Capybara::Node::Matcher の `has_selector?` を利用しました。

`<input>` タグは以下のようにマッチします：

```rb
# console
> html = Capybara.string('<input type="text" name="user_name">')
> html.has_selector?('input')
=> true
```

同じ方法で `<link>` や `<meta>` はマッチしません：

```rb
# console
> html = Capybara.string('<link href="http://example.com" rel="stylesheet" />')
> html.has_selector?('link')
=> false

> html = Capybara.string('<meta name="description" content="概要" />')
> html.has_selector?('meta')
=> false
```

明らかにそのタグが書かれているにも関わらず、なぜマッチできないのでしょう。

## ドキュメント・メタデータの HTML タグを capybara で match させるには？

いきなり結論ですが、matcher に `visible: false` オプションを指定すれば、メタデータのタグでもマッチさせることができます：

```rb
html = '<link href="http://www.example.com/style.css" rel="stylesheet" />'
url = 'http://www.example.com/style.css'

# オプション visible: false を指定
expect(html).to have_selector("link[href='#{url}'][rel='stylesheet']", visible: false)
```

いちいち `visible: false` オプションを付けたくない場合、メタデータに対してたくさんのテストがある場合などは Capybara.configure で以下のように設定します：

```rb
# spec_helper.rb
Capybara.configure do |config|
  config.ignore_hidden_elements = false
end
```

この設定は `capybara 2.1.0` (2013年4月頃) からデフォルトが `true` です。これによってメタデータなどの **「人に見えるコンテンツ」ではないものがマッチしないように** なっています。

feature spec など「ユーザから見てどういう振る舞いが期待されるか」をテストするのであれば、この定義はもっともであると考えられます。

ご参考までに console での実行結果も確認してみます：

```rb
# console
> html = Capybara.string('<link href="http://example.com" rel="stylesheet" />')
> html.has_selector?('link', visible: false)
=> true

> html = Capybara.string('<meta name="description" content="概要" />')
> html.has_selector?('meta', visible: false)
=> true
```

### visible オプションについて

`capybara 2.4.1` の API ドキュメントでは[この辺り](http://www.rubydoc.info/gems/capybara/2.4.1/Capybara/Node/Finders#all-instance_method)にオプションの説明があります。

> Options Hash (options):
> 
> * visible (Boolean) — Only find elements that are visible on the page. Setting this to false finds invisible and visible elements.

最新版（執筆時点で 2.4.4）では[さらにオプションが増えて](http://www.rubydoc.info/github/jnicklas/capybara/master/Capybara/Node/Finders#all-instance_method)いますね。

capybara の Visibility（`hidden` な要素や `display: none` な文章がどう扱われるか）については、下記の記事がシンプルにまとまっていてとても分かりやすかったのでご紹介いたします。

* [capybara 2.1 を学ぶ - willnet.in](http://willnet.in/101)

メタデータのなかでも `<title>` タグについてはオプション以外に専用のクラスが用意されており、 `have_title` macher でテストが可能です。

* [capybaraを2.1にupgradeしてテンパった方へ - リア充爆発日記](http://d.hatena.ne.jp/ria10/20130411/1365695467)

（それぞれこの記事を書きながらたどり着きました。もっと早く知っていれば…orz）

こちらからは以上です。
