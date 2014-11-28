---
title: JenkinsでサーバのCIを始めました
date: 2014-10-17 15:42 JST
authors: masutaka
tags: infrastructure, test, 
---
<a href="http://jenkins-ci.org/" target="_blank"><img src="/images/2014/10/logo-title.png" alt="logo-title" width="796" height="256" class="alignnone size-full wp-image-1047" /></a>

<p>お久しぶりです。アジャイル推進おじさん改め、サーバCIおじさんの増田です。</p>
<p>プライベートではベヨネッタ2をやっています。3rdクライマックスはクリアできそうです。最高難易度はたぶん無理です。</p>

<!--more-->

<h2>フィードフォースのサーバリポジトリ</h2>

<p>
弊社は今年の4月くらいから<a href="http://serverspec.org/" target="_blank">serverspec</a>を導入しましたが、CIはしていませんでした。構成管理にはChef-soloを使っており、GitHubのリポジトリはこのようになっております。(通常site-cookbooksには自分で作ったレシピを入れますが、submodule化して社内で共有しています。)
</p>

<ul>
  <li>server-social-plus
    <ul><li>site-cookbooks (git submodule)</li></ul></li>
  <li>server-datafeed-plus
    <ul><li>site-cookbooks (git submodule)</li></ul></li>
  <li>...
    <ul><li>site-cookbooks (git submodule)</li></ul></li>
  <li>site-cookbooks</li>
</ul>

<p>弊社はサービス毎にサーバのリポジトリを用意しているため、数が多いです。今数えたら9ありました(3月に入社してびっくりしたことの1つ)。</p>

<p>怖くてレシピを変更しづらいし、PullRequestのレビューにも時間がかかるため、最近作ったサーバでCIをはじめました。</p>

<h2>サーバのCI</h2>

<ul>
  <li>本番環境
    <ul><li>AWS</li></ul></li>
  <li>CIツール
    <ul><li>Jenkins on Gentoo Linux</li></ul></li>
  <li>構成管理
    <ul><li>Chef-solo</li></ul></li>
  <li>テストフレームワーク
    <ul><li>serverspec</li></ul></li>
</ul>

<p>特殊なことはしていなくて、このような流れです。</p>

<ol>
  <li>vagrant upでEC2インスタンスを起動</li>
  <li>knife solo cook</li>
  <li>serverspec</li>
  <li>vagrant destroy</li>
</ol>

<p>※ Gentooにはあらかじめ、Vagrantとvagrant-aws pluginをインストールしておきます。</p>

<p>サーバもCIすると、変更に強くなるしレシピが壊れたのにすぐ気づけるので良いです。本来集中すべきことに集中できますね。</p>

<p>よく言われることですが、リポジトリを作ったタイミングでCIを導入したので、負債があまりありません。反面、今までのレシピの負債が見えてしまったので対応することになりましたが。。</p>

<p>Jenkinsの設定とVagrantfile、テスト用のスクリプトはこの記事の最後に貼りました。興味あればご覧ください。</p>

<h2>最後に</h2>

<p>今回は最近始めたJenkinsを使ったサーバのCIについて書きました。</p>

<p>次回は<a href="https://circleci.com/" target="_blank">CircleCI</a>を使ったサーバのCIについて誰かが書くかもしれません(?)。Bootstrap層(aws-sdk, <a href="http://www.terraform.io/" target="_blank">terraform</a>あたり)も整理していきたいです。</p>

<h2>おまけ</h2>

<p>サーバのCIも思うところがあって、少し前<a href="/author/sugiuchi">sugiuchi</a>、<a href="/author/r-suzuki">r-suzuki</a>とこんな話をしました。</p>

<p>「確かにサーバはテスト出来ているけど、site-cookbooks自体のテストはないから、本当に正しいレシピなのか分からないよね。でもchefspec書くの？辛くない？」等々</p>

<p>どうなんでしょうね？</p>

<h2>付録</h2>

<h3>Jenkinsの設定</h3>

<ul>
  <li>AWS_ACCESS_KEY_IDとAWS_SECRET_ACCESS_KEYは環境変数でセットしており、Jenkinsの<a href="https://wiki.jenkins-ci.org/display/JENKINS/EnvInject+Plugin" target="_blank">EnvInject Plugin</a>を使っています。</li>
  <li>JenkinsからGitHubへの通知は鉄板の<a href="https://wiki.jenkins-ci.org/display/JENKINS/GitHub+pull+request+builder+plugin" target="_blank">GitHub pull request builder plugin</a>です。</li>
</ul>

<a href="/images/2014/10/jenkins-settings.png"><img src="/images/2014/10/jenkins-settings-s.png" alt="jenkins-settings-s" width="480" height="1643" class="alignnone size-full wp-image-1066" /></a>

<h3>Gemfile</h3>

<pre><code>source 'https://rubygems.org'
ruby '2.1.3'

gem 'knife-solo'
gem 'rake'
gem 'serverspec'
gem 'aws-sdk'
gem 'ci_reporter_rspec'
</code></pre>

<h3>Vagrantfile</h3>

一部伏せ字です。

<pre><code># -*- mode: ruby -*-
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
      aws.subnet_id = 'subnet-********'
      aws.security_groups = ['sg-********']
      aws.keypair_name = 'socialplus'
      aws.tags = { 'Name' => 'vagrant' }
      override.ssh.username = 'root'
      override.ssh.private_key_path = '~/.ssh/socialplus.pem'
    end
  end
end
</code></pre>

<h3>script/ci.sh</h3>

<p>エラーがあれば即時終了しますが(-e)、これだけだとテスト失敗でEC2インスタンスが増え続けるため、trapで捕捉しvagrant destroyしています。</p>

<pre><code>#!/bin/sh -e

if [ ! $(which vagrant) ]; then
    echo '  x You need to install Vagrant:'
    echo '    http://www.vagrantup.com/'
    exit 1
fi

if ! vagrant plugin list | fgrep -q vagrant-aws; then
    echo '  x You need to install vagrant-aws:'
    echo '    $ vagrant plugin install vagrant-aws'
    exit 1
fi

if [ ! -f "$HOME/.ssh/socialplus.pem" ]; then
    echo '  x You need ssh private key $HOME/.ssh/socialplus.pem'
    exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo '  x You need to export $AWS_ACCESS_KEY_ID'
    exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo '  x You need to export $AWS_SECRET_ACCESS_KEY'
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
</code></pre>
