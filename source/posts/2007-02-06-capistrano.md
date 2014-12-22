---
title: Capistrano
date: 2007-02-06 22:35 JST
authors: akahige
tags: ruby, resume, 
---

##### ※ この資料について
2006年4月の勉強会資料をCapistranoのバージョンアップ（現時点では1.3.1になってました）による仕様変更などに合わせてちょっと修正したものです。 質疑応答の部分は当時のままなので最初の質問が初々しいです。

## Capistranoって何なのさ
デプロイツール デプロイ=配備

参考 : [Capistrano: Automating Application Deployment](http://manuals.rubyonrails.com/read/book/17)

一言で言うと複数のサーバ上で同時に並行してコマンドを実行できるツール。 複数のサーバで動いているサービスのデプロイを楽に行うことができる。

Rails起源なのでRailsに特化した部分もあるが、ほかのアプリケーションでも使える。  

<!--more-->

昔はSwitchTowerと呼ばれていた。はてなでも使われてる。

### 何がいいのか

- 複数サーバへの作業が効率化、自動化できる

- 定義済みの標準タスクに沿った運用をするとデプロイに必要な要件を考える手間が減って楽

- すでに決まっている運用フローを自動化するなら標準タスクをまったく無視して上書きしちゃってもいい

#### 例えば

```
$ cap httpd_config_update
$ cap restart
```

これだけですべてのサーバが新しい設定で再起動したり。 新しい設定ファイルはsubversionとかからとってくるとかね。

### Capitranoを使うための要件

#### Capistranoを実行するサーバ

- Capistranoがインストールされている（ってことはもちろんRubyも）

#### リモートのサーバたち

- POSIXシェルコマンドが実行できる
- SSH接続できる
- ユーザ名とパスワードは揃える
- Rubyは特に入ってなくてもいい

サーバが二台以上ないとあんまり楽しくありません。

## とりあえず使ってみよう

### インストール

#### Ruby
まあ適当に。ソースからでもバイナリからでもお好きに。

#### gem
ソース落としてきて。バイナリはないみたい。

#### Capistrano

```
$ sudo gem install capistrano -y
```

以下のコマンドでヘルプが表示されればオッケー

```
$ cap -h
```

### 男の簡単レシピ
インストールできたらCapistranoのレシピを書いて使ってみる。

#### otoko.rb

```ruby
set :application, "ff_tools"
 set :user, "kan"
 set :password, "pasuwa-do"

 role :local, "localhost"

 desc "say hello to all hosts"
 task :hellowello do
   run "echo Hello, $HOSTNAME for #{application}"
 end
```

### 実行
-f でレシピファイルを指定します。（昔は -r でした） -f を指定しないとデフォルトで./config/deploy.rbを読もうとします。

```
$ cap -f otoko.rb hellowello
```

ローカルホストでechoするだけのつまらないレシピ。 まあでも動かないともっとつまらないからね。とりあえずはこれで勘弁。

追加できるリモートサーバがあればちょっと面白くなる。

```
role :local, "localhost", "192.168.1.101", "192.168.1.102"
```

## レシピを書こう
レシピに含まれるのは基本的に以下の三つの要素。

- 変数
- ロール
- タスク

あと基本的にRubyの文法が全部使える。 収拾がつかなくならない程度に好きに書けと。

### 変数

```
set :変数名, 値
```

- setキーワードで定義
- Rubyの変数として参照

```ruby
set :application, "ff_tools"
 set :hellocommand, "echo Hello, $HOSTNAME"

 run "echo #{application}"
 run hellocommand
```

### ロール

```
role :ロール名, "host"[, "host2", ...]
```

- ロール名は好きに（基本はrailsにのっとってapp, web, db）
- ロール＝同じ処理を実行するサーバのグループ
- ひとつのロールに含まれるサーバを一行で全部定義することもできるし、複数行で定義することもできる
- ロールの中でもprimaryのようなフラグが作れる

```
role :app, "app01.feedforce.jp", "app02.feedforce.jp"
 role :web, "web01.feedforce.jp"
 role :web, "web02.feedforce.jp"
 role :db, "db01.feedforce.jp", :primary => true
 role :db, "db02.feedforce.jp"
 role :spider, "spider01.feedforce.jp"
```

### タスク

```
task :タスク名 do ... end
 task :タスク名, :roles => :ロール名 do ... end
 task :タスク名, :roles => [:ロール名1, :ロール名2] do ... end
 task :タスク名, :roles => :ロール名, :only => { :primary => true } do
```

- タスクはメソッドと同じようにほかのタスク内で使える
- でもメソッドじゃないから他のメソッドからは使えない
- ロールを指定しないタスクはすべてのサーバで実行される
- taskの直前の行にdescで説明を書ける

```
desc "say hello to all hosts"
 task :hellowello do
   run "echo Hello, $HOSTNAME"
 end
```

#### 豆の知識 : タスク内でタスクを呼び出したときのロール
タスクをメソッド気分で使おうとするとロールで若干はまるかもしれないので注意。

タスクはどこで呼び出されようと頑なに自分の仕事範囲（:roles）を守る。

例えば以下のようなコードがあったとする。

##### roletest.rb

```
role :app, "app01.feedforce.jp", "app02.feedforce.jp"
 role :web, "web01.feedforce.jp"
 set :application, "hogehoge"

 task :hellowello do
    run "echo Hello, $HOSTNAME"
 end

 task :helloapps, :roles => :app do
   hellowello
   run "echo $HOSTNAME is apps?"
 end
```

このコードにはhelloappsを実行したときにhellowelloがappだけに適用されて欲しいという願いを込めてみた。

##### 実行

```
$ cap -f roletest.rb helloapps
```

期待通りの結果になることを念じつつ実行。

##### 実行結果

```
loading configuration /usr/local/lib/ruby/gems/1.8/gems/capistrano-1.1.0/lib/capistrano/recipes/standard.rb
    loading configuration ./roletest.rb
  * executing task helloapps
  * executing task hellowello
  * executing "echo Hello, $HOSTNAME"
    servers: ["app01.feedforce.jp", "app02.feedforce.jp", "web01.feedforce.jp"]
    [app01.feedforce.jp] executing command
    [app02.feedforce.jp] executing command
    [web01.feedforce.jp] executing command
 ** [out :: app01.feedforce.jp] Hello, app01.rsssuite.jp
 ** [out :: app02.feedforce.jp] Hello, app02.rsssuite.jp
 ** [out :: web01.feedforce.jp] Hello, web01.rsssuite.jp
    command finished
  * executing "echo $HOSTNAME is apps?"
    servers: ["app01.feedforce.jp", "app02.feedforce.jp"]
    [app01.feedforce.jp] executing command
    [app02.feedforce.jp] executing command
 ** [out :: app01.feedforce.jp] app01.rsssuite.jp is apps?
 ** [out :: app02.feedforce.jp] app02.rsssuite.jp is apps?
    command finished
```

残念ながら願いもむなしくhellowelloはすべてのロールで実行されてしまったようだ。 その下のrunはappだけを対象に実行されたのに。

こういう時にはタスクじゃなくてメソッドを使うしかない。 でもメソッド内ではリモートにコマンドを投げるヘルパータスクが使えなくて困る。

そこで

#### Tips : タスクをメソッド内で定義

という技をできるかと思ってやってみたらできちゃった。

以下のようにする。

```ruby
def prepare_hellowello(target_roles)
   task :hellowello, :roles => target_roles do
     run "echo Hello, $HOSTNAME"
   end
 end

 task :helloapps, :roles => :app do
   prepare_hellowello :app
   hellowello
 end
```

##### 実行

```
$ cap -f roletest.rb helloapps
```

さてどうなるか。

##### 実行結果

```
loading configuration /usr/local/lib/ruby/gems/1.8/gems/capistrano-1.1.0/lib/capistrano/recipes/standard.rb
    loading configuration ./roletest.rb
  * executing task helloapps
  * executing task hellowello
  * executing "echo Hello, $HOSTNAME"
    servers: ["app01.feedforce.jp", "app02.feedforce.jp"]
    [app01.feedforce.jp] executing command
    [app02.feedforce.jp] executing command
 ** [out :: app01.feedforce.jp] Hello, app01.rsssuite.jp
 ** [out :: app02.feedforce.jp] Hello, app02.rsssuite.jp
    command finished
```

期待通り。

こんな風にすると同じタスクを対象ロールを変えつつ実行できる。 ちなみにprepare\_hellowelloを連続して対象ロールを変えて呼び出しても平気。

### 拡張タスク before\_\* - after\_\*
タスクの前後に何か処理を実行したい場合はbefore\_\*とafter\_で拡張できる

```
task: before_setup do ... end
 task: setup do ... end
 task: after_setup do ... end
```

使いどころは

- 定義済みタスクをちょこっと拡張したいとき

- 前後の処理を実行したいサーバとそうでないサーバがあるとき

## 標準タスク
Railsの運用にマッチするタスクが標準タスクとして定義されている。

### なにはなくともタスク確認 show\_tasks
desc付きのタスクを一覧表示。

rake -T のような存在。

### 便利な標準タスク shell
標準タスクの中でもshellだけは格別便利。

roleとして定義してあるすべてのサーバに対して対話的シェルを実行できる。

```
$ cap -f otoko.rb shell
```

```
* executing task shell
====================================================================
Welcome to the interactive Capistrano shell! This is an experimental
feature, and is liable to change in future releases.
--------------------------------------------------------------------
cap> echo $HOSTNAME
[establishing connection(s) to localhost, 192.168.1.101, 192.168.1.102]
    [localhost] executing command
    [192.168.1.102] executing command
    [192.168.1.101] executing command
[localhost] lb03.feedforce.jp
[192.168.1.101] web01.feedforce.jp
[192.168.1.102] web02.feedforce.jp
    command finished
cap> pwd
    [localhost] executing command
    [192.168.1.102] executing command
    [192.168.1.101] executing command
[192.168.1.102] /home/kan
[localhost] /home/kan
[192.168.1.101] /home/kan
    command finished
cap> 
cap> date > date.txt
    [localhost] executing command
    [192.168.1.102] executing command
    [192.168.1.101] executing command
    command finished
cap> cat date.txt
    [192.168.1.102] executing command
    [192.168.1.101] executing command
    [localhost] executing command
[192.168.1.102] Wed Jan 31 12:48:41 JST 2007
[192.168.1.101] Wed Jan 31 12:48:44 JST 2007
[localhost] Wed Jan 31 12:48:42 JST 2007
    command finished
cap> exit
exiting
```

あんまり複雑なことすると何がなんだかわからなくなるけど、サービスの再起動みたいな単純なコマンド投入とか確認に使える。

### その他

- アップデートはdeploy
- アップデートでおかしくなったらrollback
- DBの更新をするときはmigrate
- rollbackはDBの変更はロールバックできません
- メンテ画面表示はdisable\_web
- メンテ終了はenable\_web
- 等々...

詳しくはドキュメント嫁。

## タスクを作ろう
標準タスク以外に勝手に作ってよし。

以下はタスク内で使える便利なヘルパータスク。

| タスク名 | 説明 |
| --- | --- |
| run | 一般ユーザでコマンド実行 |
| sudo | root権限でコマンド実行 リモート側でsudoの設定をしてないと使えないよ |
| put | ファイル作成 |
| delete | ファイル削除 |
| render | Erbテンプレートをレンダリング。環境ごとにファイル内容をカスタマイズしたいときなどに |
| transaction | 一連のコマンドをトランザクションとして束ねる |
| on\_rollback | transactionをロールバックするために使う |

あとはRubyを駆使していろいろできますので。

## 拡張

### タスクライブラリ

- 汎用的に使えそうなCapistranoタスクはライブラリとして切り出すと便利
- 変数をうまく使っていろんな環境で使えるようにすると吉

#### ファイル

```
cap_task_lib.rb
```

中身はレシピと同様にタスクを定義。

#### 使うとき

```
require 'cap_task_lib'
```

レシピ内でrequire。

### 拡張ライブラリ
Capistrano自体をRubyスクリプトで拡張

以下略

つ 【 [ドキュメント](http://manuals.rubyonrails.com/read/book/17)】

## 資料で触れられなかった話題

- レシピ内で使う標準変数
- Capistranoのコマンドラインオプション

つ 【 [ドキュメント](http://manuals.rubyonrails.com/read/book/17)】

## 質疑応答

### 「:roles」とかの「:」を使うのはrubyの記法？
Ruby博士が今日は御茶ノ水に行ってしまったのでわかりません。（http://shibuyajs.org/）

調べてみたらシンボルというものだそうです。

- 文字列の代わりにハッシュのキーに使う
- 特に値に意味のない定数を使いたいときにシンボルを使う

とかするといいようです。

### 標準タスクはそのまま使えるの？
変数とロールだけ指定すれば使えます。

逆に言うと環境に合わせて変数とロールを指定することだけはする必要があります。

### セキュリティのために直接SSHで接続できないホストに対する処理は？
できません。

そのホストにSSHで接続できるマシンをCapistrano実行マシンにする必要があります。

### リモートサーバの処理の失敗はどう見る？
リモートサーバ側で標準出力への出力がこちら側に返ってくるのでそれで見る。

つまりサーバ上で直接実行するのと一緒。 失敗してもだんまりな処理の場合は成功失敗わかりません。

### 標準タスクのロールバックはどういう仕組みで？
過去のリリースをあるディレクトリに保存しておいて、そこにシンボリックリンク先変更。

### Capistrano導入する場合はディレクトリ構成とか変えないとだめ？
標準タスクの流れに沿う場合はそのとおり。

現在の自分たちの運用にあわせて独自にタスクをバリバリ作っていくならその限りではなし。

### いつ導入？
Coming Soon...

本気。

（今はとっくに導入済み)
