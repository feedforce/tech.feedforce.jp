---
title: 個人で使ってみた Docker とCoreOSとか
date: 2014-07-17 15:42 JST
authors: hoshino
tags: infrastructure, resume, 
---


こんにちは。  
技術チームの星野と申します。

社内勉強会で、Dockerfileの作り方とか、CoreOSでのDockerでのデプロイ方法の一例を紹介しました。

<!--more-->

<script async class="speakerdeck-embed" data-slide="2" data-id="6af99fb0ee670131f5bb2ac9976b5d88" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>  

↑はその際のスライドです。前半のポエムっぽい序章は、適当に読み飛ばしていただければと思います。  
個人としてDockerを試している理由は、構成管理をDockerfileというシンプルな形式で記述しようとしているところが魅力的だったからです。  
「CoreOSの発表」と言いつつ、デモでは「CentOS7」も使ったりしました(CentOS7がリリース直後だったから!!)。  
CentOS7ではsystemdがデフォルトで動いており、弊社ではCentOSを採用しているサービスも多いため、ここぞとばかりに試させていただきました。

## 補足  

あと、スライドの補足として、今回デモで動かしたCoreOSの起動〜Jenkinsコンテナ起動までのスクリプトのリンクを貼っておきます。

1. [起動スクリプト例](https://gist.github.com/hoshinotsuyoshi/627362efc554e2fd9a5f)
2. [ipxe script例](http://young-dawn-7740.herokuapp.com/script.txt)
3. [cloud-config例](https://gist.githubusercontent.com/hoshinotsuyoshi/4421f1d7754db9629903/raw/7b005f4e8438434f48b7f03b50946c9c6731c0a1/test-config.config)

ipxeやcloud-configのスクリプトは、CoreOSの公式ページに書いてあることを参考にしたのですが、  
どういうふうに書けばいいのか、あまり情報が無いところだと思っています。  
私自身インフラエンジニアではないので、事情に疎いだけかもしれませんが。  
CentOS7の影響で、systemdやDockerが使われるようになれば、もっと良いサンプルがでてくるように思います。

## 弊社のインフラ開発  

さて、弊社のインフラ開発では`Vagrant`+`Chef`+`Serverspec`での開発がメインで行われています (現在インフラのCIも検討中です)。  
chefについては [他のエントリ](http://tech.feedforce.jp/?s=chef)をご覧いただければと思います!

ちなみに私を含めアプリケーションエンジニアも、chefリポジトリのレビューをしたり、PRを投げたりしています。  
そういったことができるのが今の小さなチームの利点だと思っております!

関係ないですが、7/11当日は台風一過の日で後楽園にめでたく虹が出ました、良い思い出です(みんなそっち見てた)

<blockquote class="twitter-tweet" lang="ja"><p>見事な虹が！ <a href="http://t.co/164egNBmee">pic.twitter.com/164egNBmee</a></p>&mdash; かせいさん (@kasei_san) <a href="https://twitter.com/kasei_san/status/487533365256417280">2014, 7月 11</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

## 最後に!  

feedforceでは学生サマーインターン(技術職志望者向け)を実施します！  

<s>まだ空きがあるので、学生のかたは是非ご応募ください！</s>終了しました

