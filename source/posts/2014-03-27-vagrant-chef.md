---
title: Vagrantを使って手軽にChefを始める
date: 2014-03-27 10:43 JST
authors: sugiuchi
tags: infrastructure, resume, 
---
こんにちは。インフラ担当の杉内です。

<p>最近サーバの構成管理にchef-soloを利用していることから、社内でもcookbookの検証環境用途としてVagrantが利用されはじめています。
今回は社内勉強会で発表した内容を元に、最小限の手順でcookbookの開発ができるようになるまでを紹介しようと思います。

Chefがどんなものか試してみたい、自分でcookbookを作ってみたいが手軽に実行できるサーバを用意したいというような人向けになりますのでここでは細かい動作原理などは解説していません。
</p>

<p>環境はMac OSX Mountain Lionです。</p>

<!--more-->

<h2> 下準備 </h2>
事前に下記のインストールを済ませておいてください。

<ul>
	<li><a href="https://www.virtualbox.org/" target="_blank">VirtualBox</a>のインストール</li>
	<li><a href="http://www.vagrantup.com/" target="_blank">Vagrant</a>のインストール</li>
</ul>

<h2>vagrant init</h2>
作業用のディレクトリを作成し、vagrant initをします。

<pre><code>$ mkdir cookbook-test
$ cd cookbook-test
$ vagrant init opscode-centos-6.5 http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.5_chef-provisionerless.box</code></pre>

vagrant 1.5.0以上であれば<a href="https://vagrantcloud.com/chef/" title="vagrantcloud" target="_blank">Vagrant Cloud</a>が利用できるので下記のように実行します。

<pre><code>$ vagrant init chef/centos-6.5</code></pre>

初回はboxのダウンロードに時間がかかります。
boxにはchef社が公開しているcentos6.5を使用します。

<a href="http://opscode.github.io/bento/" title="bento" target="_blank">Bento by opscode</a>

最後にVMを起動させます。

<pre><code>$ vagrant up
$ vagrant status</code></pre>

ここまででChefを試すサーバの用意ができました。

<h2>cookbookを作成する</h2>
実際にrecipeを作っていきましょう。
サンプルレシピとしてapacheをインストールするレシピを書きます。

<pre><code>$ mkdir -p cookbooks/apache/recipe/
$ vi cookbooks/apache/recipe/default.rb

package 'httpd' do
  action :install
end</code></pre>

<h2> プロビジョニングする </h2>
さっそく作ったrecipeをサーバに適用してみましょう。
Vagrantfileにchef-soloを使う設定を記述します。

<pre><code>$ vi Vagrantfile

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
   config.vm.provision :chef_solo do |chef| # プロビジョニングにchef-soloを使用
     chef.cookbooks_path = "./cookbooks"    # cookbooksの場所を指定します
     chef.add_recipe "apache"               # apacheというrecipeを適用
   end
end</code></pre>

では実際にrecipeを適用してみます。簡単ですね。

<pre><code>$ vagrant provision</code></pre>

おそらくchef-solo または chef-client が見つからないというエラーが出たと思います。
さきほど起動させたVMにchefが入っていないために出るエラーですのでchefをインストールする必要があります。
これは下記のプラグインで簡単に解決できます。

<h2> vagrant-omnibusプラグインのインストール </h2>
このプラグインはプロビジョニング時にchef-clientがインストールされているかを検出し、指定したバージョンのchef-clientをインストールしてくれます。

<pre><code>$ vagrant plugin install vagrant-omnibus</code></pre>

インストールができたらVagrantfileに下記を追記します。

<pre><code>$ vi Vagrantfile

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
   config.omnibus.chef_version = :latest    #omnibusのプラグインを使用する
   config.vm.provision :chef_solo do |chef|
   chef.cookbooks_path = "./cookbooks"
     chef.add_recipe "apache"
   end
end</code></pre>

:latestのところは任意のバージョンを指定できます。:latestとした場合は最新バージョンが入ります。

<h2> 再度プロビジョニングする </h2>

追記をしたらもう一度同じコマンドを実行しましょう。

<pre><code>$ vagrant provision</code></pre>

すると vagrant-omnibus プラグインによってchefのインストールが始まります。
その後はchefによって apache レシピが実行され、VMにapacheがインストールされます。

さっそくVMにログインして確認してみましょう。

<pre><code>$ vagrant ssh
$ rpm -q httpd
httpd-2.2.15-29.el6.centos.x86_64</code></pre>

ちゃんとapacheがインストールされています！
基本的にはこれを繰り返し、レシピを作成していきます。

<h2> 困ったときは </h2>

Vagrantfileでchefのloglevelをdebugにしておくと出力が細かくなるので原因を特定するのに役に立つでしょう。

config.vm.provision ... の下あたりに下記を追記します。

<pre><code>chef.log_level = "debug"</code></pre>

<h2> この後は... </h2>

これでVMを立ち上げそのVMに対してレシピを実行する流れが掴めたかと思います。
とても簡単でしたがこのやり方では下記のような疑問が残るでしょう。

<ul>
	<li>chefの動作原理がよくわからない</li>
	<li>ローカルのVMでは無く遠隔地にあるサーバにレシピを適用したい</li>
</ul>

いい意味でも悪い意味でもvagrantがその辺りを吸収してくれているのであらかじめ動作を知っていないとわかりずらいところがあると思います。
本番サーバに適用する時などはローカル環境からchef-soloを実行してくれるknife-soloといったツールも必要になってきます。

次の一歩となるとknife-soloを使いリモートサーバにレシピを適用するのが良いでしょう。

また、少し前になりますが弊社blogでも概要の部分に触れた記事がありますので参考にしてください。
<a href="http://tech.feedforce.jp/chef-introduction.html" title="はじめましてChef" target="_blank">はじめましてChef</a>

<h2> 今回使ったVagrantfileとrecipe </h2>

<a href="https://github.com/critical-alert/cookbook-test" target="_blank">https://github.com/critical-alert/cookbook-test</a>