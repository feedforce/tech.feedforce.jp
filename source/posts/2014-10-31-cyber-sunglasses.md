---
title: サイバーサングラス製作記
date: 2014-10-31 10:30 JST
authors: kobayashi
tags: resume, 
---
<p>ドーモ。社内ニンジャスレイヤー推進おじさんの小林です。<br>
先日、社内勉強会にて発表した「サイバーサングラス製作記」をご紹介します</p>

<!--more-->

<h2>発表資料</h2>

<iframe style="border: 1px solid #CCC; border-width: 1px; margin-bottom: 5px; max-width: 100%;" src="//www.slideshare.net/slideshow/embed_code/38735390" width="425" height="355" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" allowfullscreen="allowfullscreen"> </iframe>

<div style="margin-bottom: 5px;">
<strong> <a title="file://www.slideshare.net/kaseisan/ss-38735390" href="//www.slideshare.net/kaseisan/ss-38735390" target="_blank">サイバーサングラス製作記</a> </strong> from <strong><a href="//www.slideshare.net/kaseisan" target="_blank" title="file://www.slideshare.net/kaseisan">誠 小林誠</a></strong>
</div>

<h2>サイバーサングラスとは?</h2>

<p>サイバーサングラスは、web小説「<a href="http://ninjaslayer.jp/" title="http://ninjaslayer.jp/">ニンジャスレイヤー</a>」に登場するガジェットです</p>

<blockquote class="twitter-tweet" lang="ja"><p>大学生らは、また雑踏に吞み込まれる。足早に歩く市民らのサイバーサングラス外側液晶面には「スミマセン」「急いでいます」「あなたに構う気がない」などの無表情な定型文LED文字が光る。中には「ビョウキ、トシヨリ、ヨロシサン」「洗練、オナタカミです」などの企業CM文章も珍しくはない。　9</p>— Ninja Slayer (@NJSLYR) <a href="https://twitter.com/NJSLYR/status/447995956655452160" title="https://twitter.com/NJSLYR/status/447995956655452160">2014, 3月 24</a></blockquote>

<script async="" src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<p>上記のように、サングラスのメガネ部分に LED 表示が光る、レトロ・フューチャー感があふれるアイテムです<br>
これを Raspberry Pi と、LED 表示器を組み合わせて DIY してみました!</p>

<h2>動作の様子(動画)</h2>

<p><object width="560" height="315"><param name="movie" value="//www.youtube.com/v/vJQ2zjitVgY?version=3&amp;hl=ja_JP"><param name="allowFullScreen" value="true"><param name="allowscriptaccess" value="always"><embed src="//www.youtube.com/v/vJQ2zjitVgY?version=3&amp;hl=ja_JP" type="application/x-shockwave-flash" width="560" height="315" allowscriptaccess="always" allowfullscreen="true"></object></p>

<h2>ソースコード</h2>

<p><a href="https://github.com/kasei-san/led_matrix" title="https://github.com/kasei-san/led_matrix">https://github.com/kasei-san/led_matrix</a></p>

<h2>補足事項</h2>

<p>制作に使用した秋月電子の LED 表示器ですが、現在(2014/10/31)品切れでした<br>
もし、自分も作ってみたい! という方が居ましたら、こちらの LED 表示器 + Arduino 等の組み合わせのほうが、敷居は低そうです</p>

<p><a href="http://akizukidenshi.com/catalog/g/gM-07764/" title="http://akizukidenshi.com/catalog/g/gM-07764/">ＲＧＢフルカラードットマトリクスＬＥＤパネル　１６ｘ３２ドット: LED(発光ダイオード) 秋月電子通商 電子部品 ネット通販</a></p>

<h2>発表時の Q&amp;A</h2>

<h3>ニンジャスレイヤーって何?</h3>

```
全米を震撼させているサイバーパンクニンジャ活劇小説「ニンジャスレイヤー」。
原作者はアメリカ人のブラッドレー・ボンドとフィリップ・ニンジャ・モーゼズ。
現在twitter上にて日本語翻訳版が連載されておりじわじわと人気を集めている。

Twitterアカウントでリアルタイム連載されているほか、有志の方によりTogetterのまとめも整備されている。詳しくはリンク集を参照。

2012年に晴れて書籍化。2013年にドラマCD化やコミカライズ、2014年にフィギュア化を果たし、2015年のアニメ化が決定するなど多方面にメディアミックスを展開し続けている。
```

<p><a href="http://wikiwiki.jp/njslyr/?%A5%CB%A5%F3%A5%B8%A5%E3%A5%B9%A5%EC%A5%A4%A5%E4%A1%BC%A4%C8%A4%CF%A1%A9" title="http://wikiwiki.jp/njslyr/?%A5%CB%A5%F3%A5%B8%A5%E3%A5%B9%A5%EC%A5%A4%A5%E4%A1%BC%A4%C8%A4%CF%A1%A9">ニンジャスレイヤーとは？ - ニンジャスレイヤー Wiki*</a></p>

<h3>秋月LEDは、どのように信号を受け取っているのか?</h3>

<ul>
<li>単純な 5V のデジタル信号です</li>
<li>Raspberry Pi の GPIO も 5V 出力なので、そのまま信号を送信しています</li>
</ul>

<h3>テキストがたまにカクカクして見える</h3>

<ul>
<li>テキストの右送りは ruby で行っているので、そこがボトルネックになっているかも…?

<ul>
<li>この部分 → <a href="https://github.com/kasei-san/led_matrix/blob/master/lib/led_intermediator.rb#L30" title="https://github.com/kasei-san/led_matrix/blob/master/lib/led_intermediator.rb#L30">https://github.com/kasei-san/led_matrix/blob/master/lib/led_intermediator.rb#L30</a></li>
</ul></li>
<li>C++での実装を検討しています</li>
</ul>

<h3>Raspberry Pi ってケース別売り?</h3>

<ul>
<li>別売りです</li>
<li>自分はこれを購入しました(1,080円) → <a href="http://www.amazon.co.jp/gp/product/B00E92JZ2O/" title="http://www.amazon.co.jp/gp/product/B00E92JZ2O/">Pi Tin for the Raspberry Pi - Clear</a></li>
</ul>

<h3>電源はどうしているの?</h3>

<ul>
<li>これを使っています → <a href="http://www.amazon.co.jp/gp/product/B00DQ7590A" title="http://www.amazon.co.jp/gp/product/B00DQ7590A">ANKER Astro M3 モバイルバッテリー 13000mAh</a></li>
<li>イベントで半日ほど使ってみましたが、十分持ちました</li>
</ul>

<h3>Raspberry Pi ベースだから、wifi つないだら夢が広がる?</h3>

<ul>
<li>wifiドングルは購入済

<ul>
<li>wifi経由で ssh 接続して開発していました</li>
</ul></li>
<li>ちょっといじればタイムラインの表示とかは楽にできます</li>
<li><a href="http://sourceforge.net/projects/siriproxyrpi/" title="http://sourceforge.net/projects/siriproxyrpi/">SiriProxy on Raspberry Pi</a> と組み合わせて、
iPhone マイクで拾った声を表示すると楽しそう…!</li>
</ul>

<h2>つけてみよう</h2>

<p><img src="https://qiita-image-store.s3.amazonaws.com/583/5329/c34a9dd1-a98b-08d8-8488-1cc28e0cd79a.jpeg" alt="写真 1.JPG" title="写真 1.JPG"><br>
<img src="https://qiita-image-store.s3.amazonaws.com/583/5329/11a1605e-c95c-c0a8-e521-60a9ce06c2f4.jpeg" alt="写真 2.JPG" title="写真 2.JPG"></p>

<p>カッコイイ!!</p>

