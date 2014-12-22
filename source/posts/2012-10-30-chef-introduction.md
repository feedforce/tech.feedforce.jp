---
title: はじめましてChef
date: 2012-10-30 11:59 JST
authors: r-suzuki
tags: infrastructure, resume, 
---
国内販売のアナウンスやSoftware Designで特集が組まれるなど注目が高まっているChef。ですが用語が多いといった「とっつきにくさ」もあるように思います。  
そこで今回は「とりあえず使ってみたい」「メリットを知りたい」という方向けにChefを紹介したいと思います。

<!--more-->

## Chefとは

ChefはRubyで実装されたサーバー構成管理ツールです。管理対象であるファイル、ユーザー、パッケージ、サービス等をどのように構成するかは、Rubyによる言語内DSLで記述します。  
つまりコードを書いて実行することでサーバーの構成管理ができるわけです。

[What is Chef? - Opscode Open Source Wiki](http://wiki.opscode.com/pages/viewpage.action?pageId=7274862)

## やってみよう

Chefには大きく分けて

- 管理対象サーバーのローカル環境で実行するスタンドアロン版
- 中央のサーバーで設定内容などを管理するクライアントサーバ版

の2つがあります。今回はスタンドアロン版(Chef Solo)を使ってみます。

[The Different Flavors of Chef - Opscode Open Source Wiki](http://wiki.opscode.com/display/chef/The+Different+Flavors+of+Chef)

### 必要なもの

Ruby1.8.7以降とRubyGems1.3.7以降が必要です。OSはLinuxディストリビューション各種、MacOSX、Windowsと幅広くサポートされています。  
今回のサンプルはCentOS6.3(x86\_64)で動作確認をしています。

[Fast Start Guide - Opscode Open Source Wiki](http://wiki.opscode.com/display/chef/Fast+Start+Guide)

### Chefのインストール

開発元のOpscodeが提供するインストーラを利用するのが手軽です。

```
$ sudo true && curl -L http://opscode.com/chef/install.sh | sudo bash
```

依存するRubyなども含め /opt/chef 以下にインストールされるので、既存環境の汚染を最少限にできるというメリットもあります。

[Installing Omnibus Chef Client on Linux and Mac - Opscode Open Source Wiki](http://wiki.opscode.com/display/chef/Installing+Omnibus+Chef+Client+on+Linux+and+Mac)

インストーラを使わない場合は以下を参照してください。

[Installing Chef Client and Chef Solo - Opscode Open Source Wiki](http://wiki.opscode.com/display/chef/Installing+Chef+Client+and+Chef+Solo)

### "Cookbook" について

Chefには料理にちなんだ用語がいくつか出てきます。  
この Cookbook とは「パッケージをインストールする」「ユーザーを作る」といった構成内容を定義した "Recipe" や、サーバーに配備する設定ファイルのテンプレートなどをひとまとめにしたものです。  
自分で作成するだけでなく、公開されているCookbookを利用することもできます。

[Introduction to Cookbooks and More - Opscode Open Source Wiki](http://wiki.opscode.com/display/chef/Introduction+to+Cookbooks+and+More)

### Cookbookなどの置き場所を用意する

Chefの動作にはCookbook以外にも色々とファイルが必要です。 [githubにひな形](https://github.com/opscode/chef-repo) があるのでこれを利用しましょう。  
chef-solo はデフォルトで /var/chef/cookbooks にCookbookがあると仮定するので、今回はここに用意します。  
設定ファイルで別の場所を指定することも可能です。

[Chef Solo - Opscode Open Source Wiki](http://wiki.opscode.com/display/chef/Chef+Solo)

### githubからひな形をダウンロード

以下の手順でgithubから雛形をダウンロードします。もちろんgitがインストールされているのであればgit cloneで構いません。

```
$ curl -o chef-repo.tar.gz -L https://github.com/opscode/chef-repo/tarball/master
$ tar zxvf chef-repo.tar.gz
$ mv opscode-chef-repo-xxxxxxx /var/chef
```

[Chef Repository - Opscode Open Source Wiki](http://wiki.opscode.com/display/chef/Chef+Repository)

### Cookbookを作る

以下を参考に、ntpのインストールと設定を行うCookbookを作ってみます。

- [Guide to Creating A Cookbook and Writing A Recipe - Opscode Open Source Wiki](http://wiki.opscode.com/display/chef/Guide+to+Creating+A+Cookbook+and+Writing+A+Recipe)

まずchefに含まれるknifeというユーティリティで空のcookbookを作ります。

```
$ cd /var/chef
$ knife cookbook create ntp -o cookbooks
```

### "Recipe" の編集

次にRecipeと呼ばれるファイルに構成内容を記述します。

cookbooks/ntp/recipes/default.rb

```
package "ntp" do # (1)
  action [:install]
end

template "/etc/ntp.conf" do # (2)
  source "ntp.conf.erb"
  variables( ntp_server: "ntp.nict.jp" )
  notifies :restart, "service[ntpd]"
end

service "ntpd" do # (3)
  action [:enable, :start]
end
```

レシピから利用するテンプレートも以下のように作成します。

cookbooks/ntp/templates/default/ntp.conf.erb

```
restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict -6 ::1
server <%= @ntp_server %>
server 127.127.1.0
driftfile /var/lib/ntp/drift
keys /etc/ntp/keys
```

上記のようにレシピを記述することにより、以下の構成が実現できます。

1. ntpパッケージがインストールされていなければインストール
2. テンプレートntp.conf.erbを使ってファイル/etc/ntp.confを上書きし、ntpdサービスを再起動
3. ntpdサービスを有効にして起動

### "Resource" について

Recipeの中で出てきたPackage, Template, ServiceなどはChefでResourceと呼ばれるものです。  
ResourceはChefで管理する構成内容を抽象化したもので、それぞれにアクションや属性が用意されています。  
独自のResourceを定義することも可能です。

[Resources - Opscode Open Source Wiki](http://wiki.opscode.com/display/chef/Resources)

### chef-solo用設定ファイル

対象のサーバー(Node)に対してどのRecipeを適用するかJSONで記述したファイルが必要です。  
今回は /var/chef/node.json として作成します。

```
{
  "run_list": ["recipe[ntp]" ]
}
```

### chef-soloの実行

以上でchef-soloを実行する準備が整いました。  
何が実行されるか確認するため、オプションを指定してログをdebugレベルで出力してみましょう。

```
$ cd /var/chef
$ sudo chef-solo -j node.json -l debug
```

ntpのインストール、設定ファイルの配備、サービスの有効化と起動がされるでしょうか。

## Chefのメリット

ごく一部ですがChefが持つ機能を使ってみることができたので、そのメリットを考えてみます。

### 自動化によるメリット

まず以下のような「自動化」によるメリットが挙げられます。

- 何度も実行することができ、毎回同じ結果が得られる
- オペレーション担当者による作業ミスといった属人性を減らすことができる
- 管理対象のサーバーが増えても苦にならない

特に「何度も実行できる」ということは継続的な変化を前提とした開発で強く求められるものではないでしょうか。

### その他のメリット

その他に以下のようなメリットが挙げられます。

- 自然言語で書かれた「手順書」などと違って曖昧さがない
- Rubyで書ける(反復や条件分岐など)
- コードで書かれているのでバージョン管理や変更の追跡が容易
- 構成管理の手間を減らすことで、より重要な作業に集中できる

## まとめ

Chefに触れていると「インフラにもアジャイルを」というメッセージが感じられます。  
サーバーは「初期構築をしたらおしまい」ではなく、運用の中で日々変更を加えていくものです。Chefはバージョン管理や反復実行を前提として作られているものなので、サービスの規模やサーバー台数に関わらず、アジャイルさが求められる現場で役立つのではないでしょうか。

