---
title: サイバーサングラス製作記
date: 2014-10-31 10:30 JST
authors: kobayashi
tags: resume, 
---
ドーモ。社内ニンジャスレイヤー推進おじさんの小林です。  
先日、社内勉強会にて発表した「サイバーサングラス製作記」をご紹介します

<!--more-->

## 発表資料

<iframe style="border: 1px solid #CCC; border-width: 1px; margin-bottom: 5px; max-width: 100%;" src="//www.slideshare.net/slideshow/embed_code/38735390" width="425" height="355" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" allowfullscreen="allowfullscreen"> </iframe>

**[サイバーサングラス製作記](//www.slideshare.net/kaseisan/ss-38735390 "file://www.slideshare.net/kaseisan/ss-38735390")** from **[誠 小林誠](//www.slideshare.net/kaseisan "file://www.slideshare.net/kaseisan")**  

## サイバーサングラスとは?

サイバーサングラスは、web小説「 [ニンジャスレイヤー](http://ninjaslayer.jp/ "http://ninjaslayer.jp/")」に登場するガジェットです

<blockquote class="twitter-tweet" lang="ja"><p>大学生らは、また雑踏に吞み込まれる。足早に歩く市民らのサイバーサングラス外側液晶面には「スミマセン」「急いでいます」「あなたに構う気がない」などの無表情な定型文LED文字が光る。中には「ビョウキ、トシヨリ、ヨロシサン」「洗練、オナタカミです」などの企業CM文章も珍しくはない。　9</p>&mdash; Ninja Slayer (@NJSLYR) <a href="https://twitter.com/NJSLYR/status/447995956655452160">2014, 3月 24</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

上記のように、サングラスのメガネ部分に LED 表示が光る、レトロ・フューチャー感があふれるアイテムです  
これを Raspberry Pi と、LED 表示器を組み合わせて DIY してみました!

## 動作の様子(動画)

<object width="560" height="315"><param name="movie" value="//www.youtube.com/v/vJQ2zjitVgY?version=3&amp;hl=ja_JP">
<param name="allowFullScreen" value="true">
<param name="allowscriptaccess" value="always">
<embed src="//www.youtube.com/v/vJQ2zjitVgY?version=3&amp;hl=ja_JP" type="application/x-shockwave-flash" width="560" height="315" allowscriptaccess="always" allowfullscreen="true"></embed></object>

## ソースコード

[https://github.com/kasei-san/led\_matrix](https://github.com/kasei-san/led_matrix "https://github.com/kasei-san/led\_matrix")

## 補足事項

制作に使用した秋月電子の LED 表示器ですが、現在(2014/10/31)品切れでした  
もし、自分も作ってみたい! という方が居ましたら、こちらの LED 表示器 + Arduino 等の組み合わせのほうが、敷居は低そうです

[ＲＧＢフルカラードットマトリクスＬＥＤパネル　１６ｘ３２ドット: LED(発光ダイオード) 秋月電子通商 電子部品 ネット通販](http://akizukidenshi.com/catalog/g/gM-07764/ "http://akizukidenshi.com/catalog/g/gM-07764/")

## 発表時の Q&A

### ニンジャスレイヤーって何?

```
全米を震撼させているサイバーパンクニンジャ活劇小説「ニンジャスレイヤー」。
原作者はアメリカ人のブラッドレー・ボンドとフィリップ・ニンジャ・モーゼズ。
現在twitter上にて日本語翻訳版が連載されておりじわじわと人気を集めている。

Twitterアカウントでリアルタイム連載されているほか、有志の方によりTogetterのまとめも整備されている。詳しくはリンク集を参照。

2012年に晴れて書籍化。2013年にドラマCD化やコミカライズ、2014年にフィギュア化を果たし、2015年のアニメ化が決定するなど多方面にメディアミックスを展開し続けている。
```

[ニンジャスレイヤーとは？ - ニンジャスレイヤー Wiki\*](http://wikiwiki.jp/njslyr/?%A5%CB%A5%F3%A5%B8%A5%E3%A5%B9%A5%EC%A5%A4%A5%E4%A1%BC%A4%C8%A4%CF%A1%A9 "http://wikiwiki.jp/njslyr/?%A5%CB%A5%F3%A5%B8%A5%E3%A5%B9%A5%EC%A5%A4%A5%E4%A1%BC%A4%C8%A4%CF%A1%A9")

### 秋月LEDは、どのように信号を受け取っているのか?

- 単純な 5V のデジタル信号です
- Raspberry Pi の GPIO も 5V 出力なので、そのまま信号を送信しています

### テキストがたまにカクカクして見える

- テキストの右送りは ruby で行っているので、そこがボトルネックになっているかも…?
  - この部分 → [https://github.com/kasei-san/led\_matrix/blob/master/lib/led\_intermediator.rb#L30](https://github.com/kasei-san/led_matrix/blob/master/lib/led_intermediator.rb#L30 "https://github.com/kasei-san/led\_matrix/blob/master/lib/led\_intermediator.rb#L30")
- C++での実装を検討しています

### Raspberry Pi ってケース別売り?

- 別売りです
- 自分はこれを購入しました(1,080円) → [Pi Tin for the Raspberry Pi - Clear](http://www.amazon.co.jp/gp/product/B00E92JZ2O/ "http://www.amazon.co.jp/gp/product/B00E92JZ2O/")

### 電源はどうしているの?

- これを使っています → [ANKER Astro M3 モバイルバッテリー 13000mAh](http://www.amazon.co.jp/gp/product/B00DQ7590A "http://www.amazon.co.jp/gp/product/B00DQ7590A")
- イベントで半日ほど使ってみましたが、十分持ちました

### Raspberry Pi ベースだから、wifi つないだら夢が広がる?

- wifiドングルは購入済
  - wifi経由で ssh 接続して開発していました
- ちょっといじればタイムラインの表示とかは楽にできます
- [SiriProxy on Raspberry Pi](http://sourceforge.net/projects/siriproxyrpi/ "http://sourceforge.net/projects/siriproxyrpi/") と組み合わせて、 iPhone マイクで拾った声を表示すると楽しそう…!

## つけてみよう

![写真 1.JPG](https://qiita-image-store.s3.amazonaws.com/583/5329/c34a9dd1-a98b-08d8-8488-1cc28e0cd79a.jpeg "写真 1.JPG")  
![写真 2.JPG](https://qiita-image-store.s3.amazonaws.com/583/5329/11a1605e-c95c-c0a8-e521-60a9ce06c2f4.jpeg "写真 2.JPG")

カッコイイ!!
