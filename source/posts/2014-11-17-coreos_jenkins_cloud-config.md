---
title: 貧者のためのCoreOS(Jenkinsを例に)
date: 2014-11-17 10:25 JST
authors: hoshino
tags: resume, 
---
こんにちは。

CoreOS大好きおじさん星野です。

社内勉強会で、また懲りずにCoreOSの話をしました。

(<a href="/docker_coreos.html">前回</a>はDockerfileの書き方を話しました)

<!--more-->

今回は
<ul>
	<li>「こんなに簡単にJenkinsとか立てられるんですよ！」</li>
	<li>「しかもCoreOSならこんなにポータビリティが高い！」</li>
	<li>「そしてVPSはなんか安い！」</li>
</ul>
みたいな徒然を話しました。

<script async class="speakerdeck-embed" data-id="92a85c504c84013292632a533d39c347" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

だらだらと話してしまったので、以下、4点ポイントとしてまとめたいと思います
<h2>cloud-configの高いポータビリティ</h2>
CoreOSはクラスタ管理が得意なOSですが、私は個人的には<a href="https://coreos.com/docs/cluster-management/setup/cloudinit-cloud-config/">cloud-config</a>という仕組みが好きです。

これにより、yamlファイルひとつで「サーバーが起動するサービスや設定」を記述することができます。

今回、DigitalOceanとVultrでデモをしたのですが、どちらのVPSサービスでも同じyamlで同じテスト環境(Jenkinsが立つだけですが)を構築することが出来ました。

この「ポータビリティの高さ」と「Immutable感」が嬉しい限りです。

今回デモで使用したJenkinsサーバーを立てるyamlはここに貼っておきます。

<a href="https://gist.github.com/hoshinotsuyoshi/8d3dc38d50c61c1b6cd3">https://gist.github.com/hoshinotsuyoshi/8d3dc38d50c61c1b6cd3</a>
<h2>お安いVPSプラン</h2>
スライド内で紹介した、CoreOSをサポートするVPS(DigitalOcean, Vultr)には、どちらもお安いプランが有ります。
「プライベートなJenkinsサーバを、週末だけ、安く立てたい」とか、そういうニッチな用途には向いていると思います。
<h3>DigitalOcean</h3>
<li>一番安いプラン …  $5/mon = $0.007/hour</li>
<li>CoreOS / cloud-config …  利用可能</li>
<h3>Vultr</h3>
<li>一番安いプラン …  $5/mon = $0.007/hour</li>
<li>CoreOS / cloud-config …  利用可能</li>

<h2>docker hub で docker imageを自動ビルドできる</h2>
「貧者のための…」がテーマなので、公式のdocker hub(public、無料)を利用しています。

githubと連携できる「AUTOMATED BUILD REPOSITORY」を利用すると、githubへのプッシュをフックにビルドでき、便利です。

<a href="https://docs.docker.com/docker-hub/builds/">AUTOMATED BUILD REPOSITORY - docs.docker.com</a>
<h2>個別の設定をdocker imageに注入する</h2>
publicなdocker hubを使っていると、個別の設定・パスワードなど、公開するdocker imageやgithubリポジトリに入れるべきでないデータをどうするべきか？ ということがあると思います。

etcdとかを使うのも良いと思いますが、今回はサーバー1台だけなので、

個別の設定はcloud-configの"write-files"でファイルを生成し、docker buildで注入するのが良いと思います。

具体的には今回は、Jenkinsのが立ち上がった時点でカスタムジョブ(個別の設定)がセットされている状態になって欲しかったので
<ol>
<li>cloud-configの"write-files:"で、Jenkinsのカスタムジョブを記述したconfig.xml を生成</li>
<li>子imageを docker build</li>
</ol>
ということをやっています。

これにより「サーバーを初めて起動した時にはすでに(config.xmlに書かれた)Jenkinsのジョブがセットされている」ということを実現できました。
<h2>参考・関連リンク</h2>
今回参考にしたDigitalOceanとVultrのドキュメントなどはこちらです。
<ul>
	<li><a href="https://www.digitalocean.com/community/tutorials/how-to-set-up-a-coreos-cluster-on-digitalocean">How To Set Up a CoreOS Cluster on DigitalOcean - DigitalOcean</a></li>
	<li><a href="https://coreos.com/docs/running-coreos/cloud-providers/vultr/">Vultr VPS - CoreOS</a></li>
</ul>
