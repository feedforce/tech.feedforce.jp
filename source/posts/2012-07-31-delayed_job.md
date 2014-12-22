---
title: Delayed_job についてちょっと詳しく
date: 2012-07-31 10:14 JST
authors: ff_koshigoe
tags: ruby, resume, 
---
自分が知る Ruby 製ジョブキューの中で最も手軽なジョブキューだと思う Delayed\_job について、ほんの少しだけ詳しく調べた内容を社内勉強会で発表しました。

その発表の際に使ったスライドを公開します。

<!--more-->  

### 発表資料

[Delayed\_job についてちょっと詳しく](https://docs.google.com/presentation/d/1a8cw1n3EHAdqz8t2Z1EtSNbHZ6z9-cYJDoRyDPMwvXM/edit)

### 質疑応答

#### enqueue時のシリアライズで ActiveRecord どうなる？

YAML の to\_yaml/load を使います。

#### ワーカーはどうやってジョブをタイムアウトさせる？

Timeout.timeout を使います。

#### 失敗した時に再実行させたくない場合は？

Delayed::Worker.max\_attempts を 1 とすれば、そのワーカーで実行される再実行しなくなります。

ペイロードオブジェクトが max\_attempts に応答出来れば、その値を最大試行回数とします。

#### ワーカーの名前はどう決まる？

基本的にはうまいこと決めてくれます。

```
"#{@name_prefix}host:#{Socket.gethostname} pid:#{Process.pid}" rescue "#{@name_prefix}pid:#{Process.pid}"
```

デーモンスクリプトの -p/--prefix を使ってプレフィクスを指定する事もできます。

### まとめ

自分が名前を知っている Ruby 製ジョブキューは、Delayed\_job と Resque と Sidekiq の 3 つだけです。その中で Delayed\_job が手軽だと考えるのは、セットアップの容易さと利用の容易さがあるからです。

サービスを Rails で開発している場合、大抵は ActiveRecord を使うと思います。そうであれば、その時点で Delayed\_job の環境はできあがっている様なものです。後は、Gemをインストールしてテーブルを用意したら、デーモン(ワーカー)を立ち上げるだけ。(ワーカーの運用・保守について考える必要はありますが。)

delay メソッドや handle\_asynchronously を使えば、既存のメソッドを簡単に遅延処理にすることが出来ます。もちろん、バックグラウンド処理専用のクラスを作り、それをキューに登録する事もできます。

一方 ResqueとSidekiqは、ジョブの数が膨大なケースで役に立つのだろうという認識でいます。ほどほどの用途であれば、Delayed\_job は良い選択肢だと思いますがいかがでしょうか。

