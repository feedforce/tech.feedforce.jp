---
title: JenkinsでサーバのCIを始めました
date: 2014-10-17 15:42 JST
authors: masutaka
tags: infrastructure, test
---
 [![logo-title](/images/2014/10/logo-title.png)](http://jenkins-ci.org/)

お久しぶりです。アジャイル推進おじさん改め、サーバCIおじさんの増田です。

プライベートではベヨネッタ2をやっています。3rdクライマックスはクリアできそうです。最高難易度はたぶん無理です。

2015.3.13 追記
社内で共有するレシピのリポジトリをsite-cookbooksからff-cookbooksに変更しました。

<!--more-->

## フィードフォースのサーバリポジトリ

弊社は今年の4月くらいから [serverspec](http://serverspec.org/)を導入しましたが、CIはしていませんでした。構成管理にはChef-soloを使っており、GitHubのリポジトリはこのようになっております(数字は参照順です)。

- server-social-plus
    1. site-cookbooks
    2. cookbooks
    3. ff-cookbooks (git submodule)
- server-datafeed-plus
    1. site-cookbooks
    2. cookbooks
    3. ff-cookbooks (git submodule)
- ...
    1. site-cookbooks
    2. cookbooks
    3. ff-cookbooks (git submodule)
- ff-cookbooks

Chefデフォルトのcookbooks、site-cookbooksに加え、社内でff-cookbooksを共有しています。

弊社はサービス毎にサーバのリポジトリを用意しているため、数が多いです。今数えたら9ありました(3月に入社してびっくりしたことの1つ)。

怖くてレシピを変更しづらいし、PullRequestのレビューにも時間がかかるため、最近作ったサーバでCIをはじめました。

## サーバのCI
- 本番環境
  - AWS
- CIツール
  - Jenkins on Gentoo Linux
- 構成管理
  - Chef-solo
- テストフレームワーク
  - serverspec

特殊なことはしていなくて、このような流れです。

1. vagrant upでEC2インスタンスを起動
2. knife solo cook
3. serverspec
4. vagrant destroy

※ Gentooにはあらかじめ、Vagrantとvagrant-aws pluginをインストールしておきます。

サーバもCIすると、変更に強くなるしレシピが壊れたのにすぐ気づけるので良いです。本来集中すべきことに集中できますね。

よく言われることですが、リポジトリを作ったタイミングでCIを導入したので、負債があまりありません。反面、今までのレシピの負債が見えてしまったので対応することになりましたが。。

Jenkinsの設定とVagrantfile、テスト用のスクリプトはこの記事の最後に貼りました。興味あればご覧ください。

## 最後に

今回は最近始めたJenkinsを使ったサーバのCIについて書きました。

次回は [CircleCI](https://circleci.com/)を使ったサーバのCIについて誰かが書くかもしれません(?)。Bootstrap層(aws-sdk, [terraform](http://www.terraform.io/)あたり)も整理していきたいです。

## おまけ

サーバのCIも思うところがあって、少し前 [sugiuchi](http://tech.feedforce.jp/author/sugiuchi)、 [r-suzuki](http://tech.feedforce.jp/author/r-suzuki)とこんな話をしました。

「確かにサーバはテスト出来ているけど、ff-cookbooks自体のテストはないから、本当に正しいレシピなのか分からないよね。でもchefspec書くの？辛くない？」等々

どうなんでしょうね？

## 付録

### Jenkinsの設定
- AWS\_ACCESS\_KEY\_IDとAWS\_SECRET\_ACCESS\_KEYは環境変数でセットしており、Jenkinsの [EnvInject Plugin](https://wiki.jenkins-ci.org/display/JENKINS/EnvInject+Plugin)を使っています。- JenkinsからGitHubへの通知は鉄板の [GitHub pull request builder plugin](https://wiki.jenkins-ci.org/display/JENKINS/GitHub+pull+request+builder+plugin)です。

 [![jenkins-settings-s](/images/2014/10/jenkins-settings-s.png)](/images/2014/10/jenkins-settings.png)

### Gemfile

```
source 'https://rubygems.org'
ruby '2.1.3'

gem 'knife-solo'
gem 'rake'
gem 'serverspec'
gem 'aws-sdk'
gem 'ci_reporter_rspec'
```

### Vagrantfile

一部伏せ字です。

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define :gw do |gw|
    gw.vm.box = "chef/centos-6.5"
    gw.vm.network "private_network", ip: "192.168.33.21"
    gw.cache.scope = :box if Vagrant.has_plugin? 'vagrant-cachier'
  end

 config.vm.define :app do |app|
    app.vm.box = "chef/centos-6.5"
    app.vm.network "private_network", ip: "192.168.33.23"
    app.cache.scope = :box if Vagrant.has_plugin? 'vagrant-cachier'
  end

 config.vm.define :ec2, autostart: false do |ec2|
    ec2.vm.box = 'dummy'
    ec2.vm.box_url = 'https://raw.githubusercontent.com/mitchellh/vagrant-aws/master/dummy.box'
    ec2.vm.synced_folder '.', '/vagrant', disabled: true
    ec2.vm.provider :aws do |aws, override|
      aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
      aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
      aws.region = 'ap-northeast-1'
      aws.instance_type = 't1.micro'
      aws.ami = 'ami-81294380'
      aws.subnet_id = 'subnet- ********'
      aws.security_groups = ['sg- ********']
      aws.keypair_name = 'socialplus'
      aws.tags = { 'Name' => 'vagrant' }
      override.ssh.username = 'root'
      override.ssh.private_key_path = '~/.ssh/socialplus.pem'
    end
  end
end
```

### script/ci.sh

エラーがあれば即時終了しますが(-e)、これだけだとテスト失敗でEC2インスタンスが増え続けるため、trapで捕捉しvagrant destroyしています。

```
#!/bin/sh -e

if [! $(which vagrant)]; then
    echo ' x You need to install Vagrant:'
    echo ' http://www.vagrantup.com/'
    exit 1
fi

if ! vagrant plugin list | fgrep -q vagrant-aws; then
    echo ' x You need to install vagrant-aws:'
    echo ' $ vagrant plugin install vagrant-aws'
    exit 1
fi

if [! -f "$HOME/.ssh/socialplus.pem"]; then
    echo ' x You need ssh private key $HOME/.ssh/socialplus.pem'
    exit 1
fi

if [-z "$AWS_ACCESS_KEY_ID"]; then
    echo ' x You need to export $AWS_ACCESS_KEY_ID'
    exit 1
fi

if [-z "$AWS_SECRET_ACCESS_KEY"]; then
    echo ' x You need to export $AWS_SECRET_ACCESS_KEY'
    exit 1
fi

vagrant -v
vagrant plugin list

vagrant up ec2 --provider=aws

vagrant ssh-config ec2 --host=ci-gw > vagrant-ssh.conf

trap 'vagrant destroy ec2 -f; rm -f vagrant-ssh.conf' 0 1 2 3 15

bundle install --path vendor/bundle --quiet
bundle exec knife solo bootstrap ci-gw -F vagrant-ssh.conf
sed -i -e 's@User root$@User dev@' vagrant-ssh.conf

bundle exec rake ci:setup:rspec spec:ci:gw
```
