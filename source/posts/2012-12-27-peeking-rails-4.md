---
title: Peeking Rails 4
date: 2012-12-27 11:42 JST
authors: ozawa
tags: ruby, resume,
---
12月14日の社内勉強会では、2013年前半にリリースされる見込みのRuby on Railsバージョン4について、最新のコードを試す方法や目に付いた新機能を紹介してみました。

## 免責

本記事の内容は開発中のソフトウェアの記事執筆時の状態に基づいています。その後の開発進捗によって実態に符合しなくなっている可能性がありますので、その点お含み置き下さい。

<!--more-->

## Rails 4とは

Rails 4は Rails 3に続くRailsのメジャーバージョンアップです。

Railsはメジャーバージョンごとに新たな考え方(パラダイム)を導入してきました。Rails 1でDRY(Don't Repeat Yourself)、CoC(Convention over Configuration)、Rails 2でRESFful、Rails 3でモジュール化などです。しかしながら、Rails 4ではとくに目立つような新たな考え方は導入されず、細かいところでより便利になっていくようです。強いて言えば、Ruby 1.8系のサポートがなくなるところが大きな差異でしょうか。

## 本日の環境

試すに当たっては、実行するRubyも新しいものを使ってみました。Rails 4の要求するRubyは1.9系なので、必ずしも本記事のように2.0のプレビュー版を使用する必要はありません。

- Ruby 2.0.0 preview2
- bundler 1.3.0.pre

2.0 preview を使用している場合、通常の gem install でインストールされる bundler 1.2系が動作しないので、1.3.0.pre を使用しています。(gem install bundler --preでインストールできます)

```
$ ruby -v
ruby 2.0.0dev (2012-12-01 trunk 38126) [x86_64-darwin12.2.1]
$ gem list
***LOCAL GEMS***
bigdecimal (1.1.0)
bundler (1.3.0.pre)
io-console (0.3)
json (1.7.1)
minitest (4.3.2)
psych (2.0.0)
rake (0.9.5)
rdoc (4.0.0.preview2)
test-unit (2.0.0.0)
```

## Rails 4を試そう

 [Railsの最新コードはgithub.comで公開](http://github.com/rails/rails)されており、現時点では開発の最先端と、いずれ公開される見込みのRails 4にさして差はない(正式リリース間近になると開発バージョンとRails 4のリリース向けの内容に差が出てきます)ので、これを使ってRailsアプリを動かしてみましょう。

### アプリケーションの作成

demoという名前のアプリケーションを作成します。

#### 空のアプリケーションの作成

個人的に、アプリごとに依存gemをわけてインストールするのが好みなので、まず空のアプリケーションを作って、その中にgemをインストールすることにします。

```
$ mkdir demo
$ cd demo
```

空のアプリケーションのディレクトリを作成してその中に移動しました。

#### 必要なgemの用意

Rails 3以降では依存するgemはbundlerを使って管理しますが、Rails 4でもそれは変わりません。

```
$ vi Gemfile
```

以下の内容でGemfileを作成します。

```
source :rubygems
gem 'rails', github: 'rails/rails'
```

--pathオプションを付けて、bundle installを実行します。

```
$ bundle install --path vendor/bundle
```

Railsがcloneされたあと、bundlerの依存関係の解決時に

```
Could not find gem 'activerecord-deprecated_finders (= 0.0.1) ruby',
which is required by gem 'rails (>= 0) ruby', in any of the sources.
```

と怒られてしまいます。

activerecord-deprecated\_findersは、Rails 4でdeprecated扱いになる、オプションをハッシュで渡すスタイルのActiveRecordのfindメソッドを提供するもので、Rails 4.0では必須の依存gemになっていますが、Rails 4.1で依存がなくなるので、4.0のうちに新しいwhereを使う流儀に対応しておきましょう。

Gemfileを編集して activerecord-deprecated\_finders への依存を追加。

```
source :rubygems
gem 'rails', github: 'rails/rails'
gem 'activerecord-deprecated_finders', github: 'rails/activerecord-deprecated_finders' #追加
```

 再度bundlerを実行すると、Railsコマンドの実行に必要なgemがひととおり vendor/bundle ディレクトリの中に配置されます。

#### アプリケーションの生成

最新のRailsのフレームワークが用意できたので、カレントディレクトリ(. = demo)を指定して初期アプリケーションを作成します。このとき --edge オプションを忘れないでください。

Gemfileを上書きするか尋ねられるので、上書きします。

```
$ bundle exec rails new . --edge
:
Your bundle is complete!
It was installed into ./vendor/bundle
```

Gemfileは以下のような内容で上書きされています。(コメントと空行は省きました)

```
source 'https://rubygems.org'
gem 'rails', github: 'rails/rails'
gem 'arel', github: 'rails/arel'
gem 'activerecord-deprecated_finders', github: 'rails/activerecord-deprecated_finders'
gem 'sqlite3'
group :assets do
  gem 'sprockets-rails', github: 'rails/sprockets-rails'
  gem 'sass-rails', github: 'rails/sass-rails'
  gem 'coffee-rails', github: 'rails/coffee-rails'
  gem 'uglifier', '>= 1.0.3'
end
gem 'jquery-rails'
gem 'turbolinks'
```

#### サーバ起動

```
$ script/rails s
=> Booting WEBrick
=> Rails 4.0.0.beta application starting in development on http://0.0.0.0:3000
=> Call with -d to detach
=> Ctrl-C to shutdown server
[2012-12-13 23:06:24] INFO WEBrick 1.3.1
[2012-12-13 23:06:24] INFO ruby 2.0.0 (2012-12-01) [x86_64-darwin12.2.1]
[2012-12-13 23:06:24] INFO WEBrick::HTTPServer#start: pid=38974 port=3000
```

目立った変化はありませんね。

ブラウザで http://localhost:3000/ にアクセスするとおなじみのウェルカムページが表示されます。

[![Rails 3までと一見変わるところのないRails 4 Welcomeページ](/images/2012/12/rails4-welcome-150x150.png "Rails 4 Welcomeページ")](/images/2012/12/rails4-welcome.png)

### おなじみのページ(?)

おなじみのページが表示されてはいるのですが、 public ディレクトリを見てみましょう。

```
$ ls public
404.html 422.html 500.html favicon.ico robots.txt
```

Rails 3まで使っていたindex.htmlファイルがありません。それでは今表示されているページの正体は何でしょうか?

サーバの出力を見てみます。

```
Started GET "/" for 127.0.0.1 at 2012-12-13 23:06:33 +0900
Processing by Rails::WelcomeController#index as HTML
  Rendered vendor/bundle/ruby/2.0.0/bundler/gems/rails-0262a18c7b0a/railties/lib/rails/templates/rails/welcome/index.html.erb (3.9ms)
Completed 200 OK in 19ms (Views: 18.1ms | ActiveRecord: 0.0ms)
```

実はRails 4では、初期トップページは組み込みのWelcomeコントローラが提供しているのでした。

## 新機能つまみぐい

以下では、生成したアプリでいくつかの新機能を試してみることにします。

### 準備

動作を見るために、User scaffoldを作成して、データを投入しておきます。

```
$ script/rails generate scaffold User name:string admin:boolean
```

マイグレーションファイルを修正して、admin 属性のデフォルトを false に変更。

```
t.boolean :admin, default: false
```

db/seeds.rb で初期データを与えておきます。

```
User.where(name: 'Alice', admin: false).first_or_create
User.where(name: 'Bob', admin: true).first_or_create
```

初期データベースを構築します。

```
$ bundle exec rake db:migrate db:seed
```

### AR not

レコードの検索条件で条件の否定を簡潔に書けるようになりました。配列にも対応しています。

```
>> User.where.not(name: 'Alice').to_sql.display
SELECT "users".* FROM "users" WHERE ("users"."name" != 'Alice')=> nil
>> User.where.not(name: ['Alice', 'Bob']).to_sql.display
SELECT "users".* FROM "users" WHERE ("users"."name" NOT IN ('Alice', 'Bob'))=> nil
#nilはdisplayメソッドの返値であってSQLの結果ではありません。
```

### TurboLinks

JavaScriptのブラウザ履歴操作APIの一部であるpushStateを利用した、PJAXという仕組みがあります。リンクをたどるタイミングで、実際にはリンクをたどらず、ページの一部だけをスクリプトで書き換えるとともに、本来の遷移先をブラウザ履歴に追加するものです。githubのリポジトリビューでディレクトリ階層をたどると表示されているコードがアニメーションして切り替わるところが有名な使用例ですね。スクリプトでページを書き換えているにもかかわらず、ブラウザで履歴を戻ることも出来ます。

Rails 4ではデフォルトで [turbolinks gem](http://github.com/rails/turbolinks)を採用して、通常のリンクをすべて自動的にPJAXに対応させてしまいます (逆にPJAXでは望ましくないリンクにはそれを表す属性を付ける)。

Turbolinksが有効な場合、すべてのページ遷移リンクのクリックがturbolinksのスクリプトで処理されるようになります。しかしながら、サーバには通常のリクエストと同様に見えるので、従来同様ページ全体のHTMLがレスポンスとして返ってきます。このあと、turbolinksスクリプトは、現在のページのbody要素をレスポンス(HTML)のbody要素で置換、一方レスポンスのhead要素はtitle要素だけを反映して他は捨ててしまいます。結果的にレスポンスのheadに含まれていたスタイルシートへのlinkや外部スクリプトを参照するscript要素が一切評価されません。これにより、パフォーマンスの向上が見込めるわけです。

欠点として、jQuery.ready のようなページ構築後にスクリプトが実行されるタイミングがなくなってしまう(最初にページをロードした時に発火するのみ)ので、対応策として、page:load イベントに同等の処理を書く必要があることに注意しましょう。

### Strong Parameters

ActiveRecordのオブジェクトを生成するときに、外部から入力されたパラメータを素通ししてしまうと、管理者権限フラグのような、取り扱いに注意を要する属性まで外部から操作できてしまう可能性があり、危険です。

今年の3月に、 [Railsアプリが持ちうる脆弱性を指摘したが相手にされず、githubをクラックして実証してしまったという事件](https://github.com/blog/1068-public-key-security-vulnerability-and-mitigation)がありましたが、これがまさにその問題を突いた攻撃でした。

Rails 3までの対策は、ActiveRecordのサブクラスで `attr_accessible` や `attr_protected` を使用して、インスタンスの生成時にハッシュで与える初期パラメータをフィルタリングするというものでした。

しかし、このやり方には、パラメータの出所が外部である場合の問題なのに常に適用されてしまうという筋の悪さがあります。

Rails 4では、Strong Parametersという仕組みを導入し、外界との仲立ちをするコントローラでパラメータのフィルタリングを行うようになりました。

先ほど生成したuser scaffoldのuser\_controller.rbを見ると以下のようなコードがあります。

createメソッド冒頭  

```
def create
  @user = User.new(user_params)
  :
```

末尾  

```
def user_params
  params.require(:user).permit(:name, :admin)
end
```

これがStrong Parametersの使用例です。

Rails 3まではActionControllerのparamsはHashWithIndifferentAccessのインスタンスでしたが、Rails 4ではActionController::Parametersのインスタンスになっています。このクラスは、以下のような拡張が行われたHashWithIndifferentAccessのサブクラスです。

- 許可するキーのリストを持っており、許可されていればそのまま返す。許可されていなければnilを返す。
- 必須のキーのリストも持っており、与えられていないのにアクセスがあると例外を発生させます。
- requireメソッド: パラメータのうち必須のものを引数にとり、それが存在すればその値を(Hashならば再帰的にActionController::Parametersのインスタンスとして)返し、指定されていなければ例外を発生させます。
- permitメソッド: パラメータのうち許可するものだけからなる部分集合を返します。

Scaffoldで作られた user\_params のままだと、全てのパラメータを許可していますので、ユーザーの新規作成時に admin 属性を有効にして作成すると、誰でも管理権限のあるユーザーを作ることが出来てしまいます。

[![admin属性を許可した状態で、admin属性を有効にしてユーザー生成を試みる](/images/2012/12/create_with_admin_permitted-150x150.png "admin属性を許可した状態でadmin権限のあるユーザーを作成")](/images/2012/12/create_with_admin_permitted.png)

[![](/images/2012/12/created_with_admin_permitted-150x150.png "admin権限のあるユーザーが生成された")](/images/2012/12/created_with_admin_permitted.png)

そこで、以下のように name のみを許可するように変更してみましょう。

```
def user_params
  params.require(:user).permit(:name)
end
```

生成してみます。

[![admin属性を許可しない状態で、admin属性を有効にしてユーザー生成を試みる](/images/2012/12/create_without_admin_permitted-150x150.png "admin権限を許可しない状態でadmin権限のあるユーザーを生成")](/images/2012/12/create_without_admin_permitted.png)

[![admin権限のあるユーザーの生成を試みたが阻止された](/images/2012/12/created_without_admin_permitted-150x150.png "admin権限のないユーザーを生成した")](/images/2012/12/created_without_admin_permitted.png)

 今度はadmin権限を外部から設定されてしまう事態を回避できました。

## おわりに

Rails 4でアプリケーションを動かす方法と、いくつかの新機能を紹介してみました。

年末年始に遊んでみるのにちょうどよいのではないでしょうか。
