---
title: はじめましてChef
date: 2012-10-30 11:59 JST
authors: r-suzuki
tags: infrastructure, resume, 
---
<p>国内販売のアナウンスやSoftware Designで特集が組まれるなど注目が高まっているChef。ですが用語が多いといった「とっつきにくさ」もあるように思います。<br />
そこで今回は「とりあえず使ってみたい」「メリットを知りたい」という方向けにChefを紹介したいと思います。</p>

<!--more-->

<h2>Chefとは</h2>

<p>ChefはRubyで実装されたサーバー構成管理ツールです。管理対象であるファイル、ユーザー、パッケージ、サービス等をどのように構成するかは、Rubyによる言語内DSLで記述します。<br />
つまりコードを書いて実行することでサーバーの構成管理ができるわけです。</p>

<p><a href="http://wiki.opscode.com/pages/viewpage.action?pageId=7274862">What is Chef? - Opscode Open Source Wiki</a></p>

<h2>やってみよう</h2>

<p>Chefには大きく分けて</p>

<ul>
<li>管理対象サーバーのローカル環境で実行するスタンドアロン版</li>
<li>中央のサーバーで設定内容などを管理するクライアントサーバ版</li>
</ul>

<p>の2つがあります。今回はスタンドアロン版(Chef Solo)を使ってみます。</p>

<p><a href="http://wiki.opscode.com/display/chef/The+Different+Flavors+of+Chef">The Different Flavors of Chef - Opscode Open Source Wiki</a></p>

<h3>必要なもの</h3>

<p>Ruby1.8.7以降とRubyGems1.3.7以降が必要です。OSはLinuxディストリビューション各種、MacOSX、Windowsと幅広くサポートされています。<br />
今回のサンプルはCentOS6.3(x86_64)で動作確認をしています。</p>

<p><a href="http://wiki.opscode.com/display/chef/Fast+Start+Guide">Fast Start Guide - Opscode Open Source Wiki</a></p>

<h3>Chefのインストール</h3>

<p>開発元のOpscodeが提供するインストーラを利用するのが手軽です。</p>

```
$ sudo true &amp;&amp; curl -L http://opscode.com/chef/install.sh | sudo bash

```

<p>依存するRubyなども含め /opt/chef 以下にインストールされるので、既存環境の汚染を最少限にできるというメリットもあります。</p>

<p><a href="http://wiki.opscode.com/display/chef/Installing+Omnibus+Chef+Client+on+Linux+and+Mac">Installing Omnibus Chef Client on Linux and Mac - Opscode Open Source Wiki</a></p>

<p>インストーラを使わない場合は以下を参照してください。</p>

<p><a href="http://wiki.opscode.com/display/chef/Installing+Chef+Client+and+Chef+Solo">Installing Chef Client and Chef Solo - Opscode Open Source Wiki</a></p>

<h3>"Cookbook" について</h3>

<p>Chefには料理にちなんだ用語がいくつか出てきます。<br />
この Cookbook とは「パッケージをインストールする」「ユーザーを作る」といった構成内容を定義した "Recipe" や、サーバーに配備する設定ファイルのテンプレートなどをひとまとめにしたものです。<br />
自分で作成するだけでなく、公開されているCookbookを利用することもできます。</p>

<p><a href="http://wiki.opscode.com/display/chef/Introduction+to+Cookbooks+and+More">Introduction to Cookbooks and More - Opscode Open Source Wiki</a></p>

<h3>Cookbookなどの置き場所を用意する</h3>

<p>Chefの動作にはCookbook以外にも色々とファイルが必要です。 <a href="https://github.com/opscode/chef-repo">githubにひな形</a> があるのでこれを利用しましょう。<br />
chef-solo はデフォルトで /var/chef/cookbooks にCookbookがあると仮定するので、今回はここに用意します。<br />
設定ファイルで別の場所を指定することも可能です。</p>

<p><a href="http://wiki.opscode.com/display/chef/Chef+Solo">Chef Solo - Opscode Open Source Wiki</a></p>

<h3>githubからひな形をダウンロード</h3>

<p>以下の手順でgithubから雛形をダウンロードします。もちろんgitがインストールされているのであればgit cloneで構いません。</p>

```
$ curl -o chef-repo.tar.gz -L https://github.com/opscode/chef-repo/tarball/master
$ tar zxvf chef-repo.tar.gz
$ mv opscode-chef-repo-xxxxxxx /var/chef

```

<p><a href="http://wiki.opscode.com/display/chef/Chef+Repository">Chef Repository - Opscode  Open Source Wiki</a></p>

<h3>Cookbookを作る</h3>

<p>以下を参考に、ntpのインストールと設定を行うCookbookを作ってみます。</p>

<ul>
<li><a href="http://wiki.opscode.com/display/chef/Guide+to+Creating+A+Cookbook+and+Writing+A+Recipe">Guide to Creating A Cookbook and Writing A Recipe - Opscode Open Source Wiki</a></li>
</ul>

<p>まずchefに含まれるknifeというユーティリティで空のcookbookを作ります。</p>

```
$ cd /var/chef
$ knife cookbook create ntp -o cookbooks

```

<h3>"Recipe" の編集</h3>

<p>次にRecipeと呼ばれるファイルに構成内容を記述します。</p>

<p>cookbooks/ntp/recipes/default.rb</p>

```
package &quot;ntp&quot; do  # (1)
  action [:install]
end

template &quot;/etc/ntp.conf&quot; do  # (2)
  source &quot;ntp.conf.erb&quot;
  variables( ntp_server: &quot;ntp.nict.jp&quot; )
  notifies :restart, &quot;service[ntpd]&quot;
end

service &quot;ntpd&quot; do  # (3)
  action [:enable, :start]
end

```

<p>レシピから利用するテンプレートも以下のように作成します。</p>

<p>cookbooks/ntp/templates/default/ntp.conf.erb</p>

```
restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict -6 ::1
server &lt;%= @ntp_server %&gt;
server  127.127.1.0
driftfile /var/lib/ntp/drift
keys /etc/ntp/keys

```

<p>上記のようにレシピを記述することにより、以下の構成が実現できます。</p>

<ol>
<li>ntpパッケージがインストールされていなければインストール</li>
<li>テンプレートntp.conf.erbを使ってファイル/etc/ntp.confを上書きし、ntpdサービスを再起動</li>
<li>ntpdサービスを有効にして起動</li>
</ol>

<h3>"Resource" について</h3>

<p>Recipeの中で出てきたPackage, Template, ServiceなどはChefでResourceと呼ばれるものです。<br />
ResourceはChefで管理する構成内容を抽象化したもので、それぞれにアクションや属性が用意されています。<br />
独自のResourceを定義することも可能です。</p>

<p><a href="http://wiki.opscode.com/display/chef/Resources">Resources - Opscode Open Source Wiki</a></p>

<h3>chef-solo用設定ファイル</h3>

<p>対象のサーバー(Node)に対してどのRecipeを適用するかJSONで記述したファイルが必要です。<br />
今回は /var/chef/node.json として作成します。</p>

```
{
  &quot;run_list&quot;: [ &quot;recipe[ntp]&quot; ]
}

```

<h3>chef-soloの実行</h3>

<p>以上でchef-soloを実行する準備が整いました。<br />
何が実行されるか確認するため、オプションを指定してログをdebugレベルで出力してみましょう。</p>

```
$ cd /var/chef
$ sudo chef-solo -j node.json -l debug

```

<p>ntpのインストール、設定ファイルの配備、サービスの有効化と起動がされるでしょうか。</p>

<h2>Chefのメリット</h2>

<p>ごく一部ですがChefが持つ機能を使ってみることができたので、そのメリットを考えてみます。</p>

<h3>自動化によるメリット</h3>

<p>まず以下のような「自動化」によるメリットが挙げられます。</p>

<ul>
<li>何度も実行することができ、毎回同じ結果が得られる</li>
<li>オペレーション担当者による作業ミスといった属人性を減らすことができる</li>
<li>管理対象のサーバーが増えても苦にならない</li>
</ul>

<p>特に「何度も実行できる」ということは継続的な変化を前提とした開発で強く求められるものではないでしょうか。</p>

<h3>その他のメリット</h3>

<p>その他に以下のようなメリットが挙げられます。</p>

<ul>
<li>自然言語で書かれた「手順書」などと違って曖昧さがない</li>
<li>Rubyで書ける(反復や条件分岐など)</li>
<li>コードで書かれているのでバージョン管理や変更の追跡が容易</li>
<li>構成管理の手間を減らすことで、より重要な作業に集中できる</li>
</ul>

<h2>まとめ</h2>

<p>Chefに触れていると「インフラにもアジャイルを」というメッセージが感じられます。<br />
サーバーは「初期構築をしたらおしまい」ではなく、運用の中で日々変更を加えていくものです。Chefはバージョン管理や反復実行を前提として作られているものなので、サービスの規模やサーバー台数に関わらず、アジャイルさが求められる現場で役立つのではないでしょうか。</p>
