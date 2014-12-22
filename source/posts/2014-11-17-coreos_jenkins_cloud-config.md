---
title: 貧者のためのCoreOS(Jenkinsを例に)
date: 2014-11-17 10:25 JST
authors: hoshino
tags: resume, 
---
こんにちは。

CoreOS大好きおじさん星野です。

社内勉強会で、また懲りずにCoreOSの話をしました。

( [前回](http://tech.feedforce.jp/docker_coreos.html)はDockerfileの書き方を話しました)

<!--more-->

今回は

- 「こんなに簡単にJenkinsとか立てられるんですよ！」
- 「しかもCoreOSならこんなにポータビリティが高い！」
- 「そしてVPSはなんか安い！」

みたいな徒然を話しました。

<script async class="speakerdeck-embed" data-id="92a85c504c84013292632a533d39c347" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

 だらだらと話してしまったので、以下、4点ポイントとしてまとめたいと思います  

## cloud-configの高いポータビリティ
CoreOSはクラスタ管理が得意なOSですが、私は個人的には [cloud-config](https://coreos.com/docs/cluster-management/setup/cloudinit-cloud-config/)という仕組みが好きです。

これにより、yamlファイルひとつで「サーバーが起動するサービスや設定」を記述することができます。

今回、DigitalOceanとVultrでデモをしたのですが、どちらのVPSサービスでも同じyamlで同じテスト環境(Jenkinsが立つだけですが)を構築することが出来ました。

この「ポータビリティの高さ」と「Immutable感」が嬉しい限りです。

今回デモで使用したJenkinsサーバーを立てるyamlはここに貼っておきます。

[https://gist.github.com/hoshinotsuyoshi/8d3dc38d50c61c1b6cd3](https://gist.github.com/hoshinotsuyoshi/8d3dc38d50c61c1b6cd3)

## お安いVPSプラン
スライド内で紹介した、CoreOSをサポートするVPS(DigitalOcean, Vultr)には、どちらもお安いプランが有ります。 「プライベートなJenkinsサーバを、週末だけ、安く立てたい」とか、そういうニッチな用途には向いていると思います。  

### DigitalOcean

- 一番安いプラン … $5/mon = $0.007/hour
- CoreOS / cloud-config … 利用可能

### Vultr

- 一番安いプラン … $5/mon = $0.007/hour
- CoreOS / cloud-config … 利用可能

## docker hub で docker imageを自動ビルドできる
「貧者のための…」がテーマなので、公式のdocker hub(public、無料)を利用しています。

githubと連携できる「AUTOMATED BUILD REPOSITORY」を利用すると、githubへのプッシュをフックにビルドでき、便利です。

[AUTOMATED BUILD REPOSITORY - docs.docker.com](https://docs.docker.com/docker-hub/builds/)

## 個別の設定をdocker imageに注入する
publicなdocker hubを使っていると、個別の設定・パスワードなど、公開するdocker imageやgithubリポジトリに入れるべきでないデータをどうするべきか？ ということがあると思います。

etcdとかを使うのも良いと思いますが、今回はサーバー1台だけなので、

個別の設定はcloud-configの"write-files"でファイルを生成し、docker buildで注入するのが良いと思います。

具体的には今回は、Jenkinsのが立ち上がった時点でカスタムジョブ(個別の設定)がセットされている状態になって欲しかったので  

1. cloud-configの"write-files:"で、Jenkinsのカスタムジョブを記述したconfig.xml を生成
2. 子imageを docker build

ということをやっています。

これにより「サーバーを初めて起動した時にはすでに(config.xmlに書かれた)Jenkinsのジョブがセットされている」ということを実現できました。  

## 参考・関連リンク
今回参考にしたDigitalOceanとVultrのドキュメントなどはこちらです。  

- [How To Set Up a CoreOS Cluster on DigitalOcean - DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-coreos-cluster-on-digitalocean)
- [Vultr VPS - CoreOS](https://coreos.com/docs/running-coreos/cloud-providers/vultr/)

