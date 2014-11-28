---
title: 個人で使ってみた Docker とCoreOSとか
date: 2014-07-17 15:42 JST
authors: hoshino
tags: infrastructure, resume, 
---
<section id="item-c41754db5b3ffbb5b194" class="position-relative" itemprop="articleBody">

<p>こんにちは。<br>
技術チームの星野と申します。</p>
<p>社内勉強会で、Dockerfileの作り方とか、CoreOSでのDockerでのデプロイ方法の一例を紹介しました。</p>

<!--more-->

<div>
<script async class="speakerdeck-embed" data-slide="2" data-id="6af99fb0ee670131f5bb2ac9976b5d88" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>
</div>

<p>↑はその際のスライドです。前半のポエムっぽい序章は、適当に読み飛ばしていただければと思います。<br>
個人としてDockerを試している理由は、構成管理をDockerfileというシンプルな形式で記述しようとしているところが魅力的だったからです。<br>
「CoreOSの発表」と言いつつ、デモでは「CentOS7」も使ったりしました(CentOS7がリリース直後だったから!!)。<br>
CentOS7ではsystemdがデフォルトで動いており、弊社ではCentOSを採用しているサービスも多いため、ここぞとばかりに試させていただきました。</p>
<h2>
補足
</h2><p>あと、スライドの補足として、今回デモで動かしたCoreOSの起動〜Jenkinsコンテナ起動までのスクリプトのリンクを貼っておきます。</p>
<p><ol><li><a href="https://gist.github.com/hoshinotsuyoshi/627362efc554e2fd9a5f" title="" target="_blank">起動スクリプト例</a></li>
<li><a href="http://young-dawn-7740.herokuapp.com/script.txt" title="" target="_blank">ipxe script例</a></li>
<li><a href="https://gist.githubusercontent.com/hoshinotsuyoshi/4421f1d7754db9629903/raw/7b005f4e8438434f48b7f03b50946c9c6731c0a1/test-config.config" title="" target="_blank">cloud-config例</a></li></ol></p>
<p>ipxeやcloud-configのスクリプトは、CoreOSの公式ページに書いてあることを参考にしたのですが、<br>
どういうふうに書けばいいのか、あまり情報が無いところだと思っています。<br>
私自身インフラエンジニアではないので、事情に疎いだけかもしれませんが。<br>
CentOS7の影響で、systemdやDockerが使われるようになれば、もっと良いサンプルがでてくるように思います。</p>
<h2>
弊社のインフラ開発
</h2><p>さて、弊社のインフラ開発では<code>Vagrant</code>+<code>Chef</code>+<code>Serverspec</code>での開発がメインで行われています
(現在インフラのCIも検討中です)。<br>chefについては<a href="/?s=chef" title="" target="_blank">他のエントリ</a>をご覧いただければと思います!</p>
<p>ちなみに私を含めアプリケーションエンジニアも、chefリポジトリのレビューをしたり、PRを投げたりしています。<br>
そういったことができるのが今の小さなチームの利点だと思っております!</p>
<p>関係ないですが、7/11当日は台風一過の日で後楽園にめでたく虹が出ました、良い思い出です(みんなそっち見てた)</p>

<blockquote class="twitter-tweet" lang="ja"><p>見事な虹が！ <a href="http://t.co/164egNBmee">pic.twitter.com/164egNBmee</a></p>&mdash; かせいさん (@kasei_san) <a href="https://twitter.com/kasei_san/statuses/487533365256417280">2014, 7月 11</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<h2>
最後に!
</h2><p>feedforceでは学生サマーインターン(技術職志望者向け)を実施します！<br>
<s>まだ空きがあるので、学生のかたは是非ご応募ください！</s>終了しました<br>
</p>
