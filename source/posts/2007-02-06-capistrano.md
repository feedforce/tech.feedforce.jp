---
title: Capistrano
date: 2007-02-06 22:35 JST
authors: akahige
tags: ruby, resume, 
---
<h5>※ この資料について</h5>
2006年4月の勉強会資料をCapistranoのバージョンアップ（現時点では1.3.1になってました）による仕様変更などに合わせてちょっと修正したものです。
質疑応答の部分は当時のままなので最初の質問が初々しいです。

<h2>Capistranoって何なのさ</h2>
デプロイツール
デプロイ=配備

参考 : <a href="http://manuals.rubyonrails.com/read/book/17" target="_blank">Capistrano: Automating Application Deployment</a>

一言で言うと複数のサーバ上で同時に並行してコマンドを実行できるツール。
複数のサーバで動いているサービスのデプロイを楽に行うことができる。

Rails起源なのでRailsに特化した部分もあるが、ほかのアプリケーションでも使える。
<!--more-->
昔はSwitchTowerと呼ばれていた。はてなでも使われてる。

<h3>何がいいのか</h3>
<ul>
<li>複数サーバへの作業が効率化、自動化できる</li>
<li>定義済みの標準タスクに沿った運用をするとデプロイに必要な要件を考える手間が減って楽</li>
<li>すでに決まっている運用フローを自動化するなら標準タスクをまったく無視して上書きしちゃってもいい</li>
</ul>

<h4>例えば</h4>
<pre><code><code> $ cap httpd_config_update
 $ cap restart
</code></code></pre>

これだけですべてのサーバが新しい設定で再起動したり。
新しい設定ファイルはsubversionとかからとってくるとかね。

<h3>Capitranoを使うための要件</h3>
<h4>Capistranoを実行するサーバ</h4>
<ul>
<li>Capistranoがインストールされている（ってことはもちろんRubyも）</li>
</ul>
<h4>リモートのサーバたち</h4>
<ul>
<li>POSIXシェルコマンドが実行できる</li>
<li>SSH接続できる</li>
<li>ユーザ名とパスワードは揃える</li>
<li>Rubyは特に入ってなくてもいい</li>
</ul>

サーバが二台以上ないとあんまり楽しくありません。

<h2>とりあえず使ってみよう</h2>
<h3>インストール</h3>
<h4>Ruby</h4>
まあ適当に。ソースからでもバイナリからでもお好きに。

<h4>gem</h4>
ソース落としてきて。バイナリはないみたい。

<h4>Capistrano</h4>
<pre><code><code> $ sudo gem install capistrano -y
</code></code></pre>

以下のコマンドでヘルプが表示されればオッケー

<pre><code><code> $ cap -h
</code></code></pre>

<h3>男の簡単レシピ</h3>
インストールできたらCapistranoのレシピを書いて使ってみる。

<h4>otoko.rb</h4>
<pre><code><code> set :application, "ff_tools"
 set :user, "kan"
 set :password, "pasuwa-do"

 role :local, "localhost"

 desc "say hello to all hosts"
 task :hellowello do
   run "echo Hello, $HOSTNAME for #{application}"
 end
</code></code></pre>

<h3>実行</h3>
-f でレシピファイルを指定します。（昔は -r でした）
-f を指定しないとデフォルトで./config/deploy.rbを読もうとします。

<pre><code><code> $ cap -f otoko.rb hellowello
</code></code></pre>

ローカルホストでechoするだけのつまらないレシピ。
まあでも動かないともっとつまらないからね。とりあえずはこれで勘弁。

追加できるリモートサーバがあればちょっと面白くなる。

<pre><code><code> role :local, "localhost", "192.168.1.101", "192.168.1.102"
</code></code></pre>

<h2>レシピを書こう</h2>
レシピに含まれるのは基本的に以下の三つの要素。

<ul>
<li>変数</li>
<li>ロール</li>
<li>タスク</li>
</ul>

あと基本的にRubyの文法が全部使える。
収拾がつかなくならない程度に好きに書けと。

<h3>変数</h3>
<pre><code><code> set :変数名, 値
</code></code></pre>

<ul>
<li>setキーワードで定義</li>
<li>Rubyの変数として参照</li>
</ul>

<pre><code><code> set :application, "ff_tools"
 set :hellocommand, "echo Hello, $HOSTNAME"

 run "echo #{application}"
 run hellocommand
</code></code></pre>

<h3>ロール</h3>
<pre><code><code> role :ロール名, "host"[, "host2", ...]
</code></code></pre>

<ul>
<li>ロール名は好きに（基本はrailsにのっとってapp, web, db）</li>
<li>ロール＝同じ処理を実行するサーバのグループ</li>
<li>ひとつのロールに含まれるサーバを一行で全部定義することもできるし、複数行で定義することもできる</li>
<li>ロールの中でもprimaryのようなフラグが作れる</li>
</ul>

<pre><code><code> role :app, "app01.feedforce.jp", "app02.feedforce.jp"
 role :web, "web01.feedforce.jp"
 role :web, "web02.feedforce.jp"
 role :db,  "db01.feedforce.jp", :primary => true
 role :db,  "db02.feedforce.jp"
 role :spider,  "spider01.feedforce.jp"
</code></code></pre>

<h3>タスク</h3>
<pre><code><code> task :タスク名 do ... end
 task :タスク名, :roles => :ロール名 do ... end
 task :タスク名, :roles => [:ロール名1, :ロール名2] do ... end
 task :タスク名, :roles => :ロール名, :only => { :primary => true } do
</code></code></pre>

<ul>
<li>タスクはメソッドと同じようにほかのタスク内で使える</li>
<li>でもメソッドじゃないから他のメソッドからは使えない</li>
<li>ロールを指定しないタスクはすべてのサーバで実行される</li>
<li>taskの直前の行にdescで説明を書ける</li>
</ul>

<pre><code><code> desc "say hello to all hosts"
 task :hellowello do
   run "echo Hello, $HOSTNAME"
 end
</code></code></pre>

<h4>豆の知識 : タスク内でタスクを呼び出したときのロール</h4>
タスクをメソッド気分で使おうとするとロールで若干はまるかもしれないので注意。

タスクはどこで呼び出されようと頑なに自分の仕事範囲（:roles）を守る。

例えば以下のようなコードがあったとする。

<h5>roletest.rb</h5>
<pre><code><code> role :app, "app01.feedforce.jp", "app02.feedforce.jp"
 role :web, "web01.feedforce.jp"
 set :application, "hogehoge"

 task :hellowello do
    run "echo Hello, $HOSTNAME"
 end

 task :helloapps, :roles => :app do
   hellowello
   run "echo $HOSTNAME is apps?"
 end
</code></code></pre>

このコードにはhelloappsを実行したときにhellowelloがappだけに適用されて欲しいという願いを込めてみた。

<h5>実行</h5>
<pre><code><code> $ cap -f roletest.rb helloapps
</code></code></pre>

期待通りの結果になることを念じつつ実行。

<h5>実行結果</h5>
<pre><code><code> loading configuration /usr/local/lib/ruby/gems/1.8/gems/capistrano-1.1.0/lib/capistrano/recipes/standard.rb
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
</code></code></pre>

残念ながら願いもむなしくhellowelloはすべてのロールで実行されてしまったようだ。
その下のrunはappだけを対象に実行されたのに。

こういう時にはタスクじゃなくてメソッドを使うしかない。
でもメソッド内ではリモートにコマンドを投げるヘルパータスクが使えなくて困る。

そこで

<h4>Tips : タスクをメソッド内で定義</h4>

という技をできるかと思ってやってみたらできちゃった。

以下のようにする。

<pre><code><code> def prepare_hellowello(target_roles)
   task :hellowello, :roles => target_roles do
     run "echo Hello, $HOSTNAME"
   end
 end

 task :helloapps, :roles => :app do
   prepare_hellowello :app
   hellowello
 end
</code></code></pre>

<h5>実行</h5>
<pre><code><code> $ cap -f roletest.rb helloapps
</code></code></pre>

さてどうなるか。

<h5>実行結果</h5>
<pre><code><code> loading configuration /usr/local/lib/ruby/gems/1.8/gems/capistrano-1.1.0/lib/capistrano/recipes/standard.rb
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
</code></code></pre>

期待通り。

こんな風にすると同じタスクを対象ロールを変えつつ実行できる。
ちなみにprepare_hellowelloを連続して対象ロールを変えて呼び出しても平気。

<h3>拡張タスク before_* - after_*</h3>
タスクの前後に何か処理を実行したい場合はbefore_*とafter_で拡張できる

<pre><code><code> task: before_setup do ... end
 task: setup do ... end
 task: after_setup do ... end
</code></code></pre>

使いどころは

<ul>
<li>定義済みタスクをちょこっと拡張したいとき</li>
<li>前後の処理を実行したいサーバとそうでないサーバがあるとき</li>
</ul>

<h2>標準タスク</h2>
Railsの運用にマッチするタスクが標準タスクとして定義されている。

<h3>なにはなくともタスク確認 show_tasks</h3>
desc付きのタスクを一覧表示。

rake -T のような存在。

<h3>便利な標準タスク shell</h3>
標準タスクの中でもshellだけは格別便利。

roleとして定義してあるすべてのサーバに対して対話的シェルを実行できる。

<pre><code><code> $ cap -f otoko.rb shell
</code></code></pre>

<pre><code><code> * executing task shell
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
</code></code></pre>

あんまり複雑なことすると何がなんだかわからなくなるけど、サービスの再起動みたいな単純なコマンド投入とか確認に使える。

<h3>その他</h3>
<ul>
<li>アップデートはdeploy</li>
<li>アップデートでおかしくなったらrollback</li>
<li>DBの更新をするときはmigrate</li>
<li>rollbackはDBの変更はロールバックできません</li>
<li>メンテ画面表示はdisable_web</li>
<li>メンテ終了はenable_web</li>
<li>等々...</li>
</ul>

詳しくはドキュメント嫁。

<h2>タスクを作ろう</h2>
標準タスク以外に勝手に作ってよし。

以下はタスク内で使える便利なヘルパータスク。

<table>
<tr><th>タスク名</th><th>説明</th></tr>
<tr><td>run</td> <td>一般ユーザでコマンド実行</td></tr>
<tr><td>sudo</td> <td>root権限でコマンド実行 リモート側でsudoの設定をしてないと使えないよ</td></tr>
<tr><td>put</td> <td>ファイル作成</td></tr>
<tr><td>delete</td> <td>ファイル削除</td></tr>
<tr><td>render</td> <td>Erbテンプレートをレンダリング。環境ごとにファイル内容をカスタマイズしたいときなどに</td></tr>
<tr><td>transaction</td> <td>一連のコマンドをトランザクションとして束ねる</td></tr>
<tr><td>on_rollback</td> <td>transactionをロールバックするために使う</td></tr>
</table>

あとはRubyを駆使していろいろできますので。

<h2>拡張</h2>
<h3>タスクライブラリ</h3>
<ul>
<li>汎用的に使えそうなCapistranoタスクはライブラリとして切り出すと便利</li>
<li>変数をうまく使っていろんな環境で使えるようにすると吉</li>
</ul>

<h4>ファイル</h4>
<pre><code><code> cap_task_lib.rb
</code></code></pre>

中身はレシピと同様にタスクを定義。

<h4>使うとき</h4>
<pre><code><code> require 'cap_task_lib'
</code></code></pre>

レシピ内でrequire。

<h3>拡張ライブラリ</h3>
Capistrano自体をRubyスクリプトで拡張

以下略

つ 【<a href="http://manuals.rubyonrails.com/read/book/17" target="_blank">ドキュメント</a>】

<h2>資料で触れられなかった話題</h2>
<ul>
<li>レシピ内で使う標準変数</li>
<li>Capistranoのコマンドラインオプション</li>
</ul>

つ 【<a href="http://manuals.rubyonrails.com/read/book/17" target="_blank">ドキュメント</a>】

<h2>質疑応答</h2>
<h3>「:roles」とかの「:」を使うのはrubyの記法？</h3>
Ruby博士が今日は御茶ノ水に行ってしまったのでわかりません。（http://shibuyajs.org/）

調べてみたらシンボルというものだそうです。

<ul>
<li> 文字列の代わりにハッシュのキーに使う</li>
<li> 特に値に意味のない定数を使いたいときにシンボルを使う</li>
</ul>

とかするといいようです。

<h3>標準タスクはそのまま使えるの？</h3>
変数とロールだけ指定すれば使えます。

逆に言うと環境に合わせて変数とロールを指定することだけはする必要があります。

<h3>セキュリティのために直接SSHで接続できないホストに対する処理は？</h3>
できません。

そのホストにSSHで接続できるマシンをCapistrano実行マシンにする必要があります。

<h3>リモートサーバの処理の失敗はどう見る？</h3>
リモートサーバ側で標準出力への出力がこちら側に返ってくるのでそれで見る。

つまりサーバ上で直接実行するのと一緒。
失敗してもだんまりな処理の場合は成功失敗わかりません。

<h3>標準タスクのロールバックはどういう仕組みで？</h3>
過去のリリースをあるディレクトリに保存しておいて、そこにシンボリックリンク先変更。

<h3>Capistrano導入する場合はディレクトリ構成とか変えないとだめ？</h3>
標準タスクの流れに沿う場合はそのとおり。

現在の自分たちの運用にあわせて独自にタスクをバリバリ作っていくならその限りではなし。

<h3>いつ導入？</h3>
Coming Soon...

本気。

（今はとっくに導入済み)