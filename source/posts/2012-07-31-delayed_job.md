---
title: Delayed_job についてちょっと詳しく
date: 2012-07-31 10:14:49
authors: ff_koshigoe
tags: ruby, resume, 
---
<div>
  <p>自分が知る Ruby 製ジョブキューの中で最も手軽なジョブキューだと思う Delayed_job について、ほんの少しだけ詳しく調べた内容を社内勉強会で発表しました。</p>
  <p>その発表の際に使ったスライドを公開します。</p>
</div>
<!--more-->
<div>
  <h3>発表資料</h3>
  <p><a href="https://docs.google.com/presentation/d/1a8cw1n3EHAdqz8t2Z1EtSNbHZ6z9-cYJDoRyDPMwvXM/edit">Delayed_job についてちょっと詳しく</a></p>
</div>
<div>
  <h3>質疑応答</h3>
  <div>
    <h4>enqueue時のシリアライズで ActiveRecord どうなる？</h4>
    <p>YAML の to_yaml/load を使います。</p>
  </div>
  <div>
    <h4>ワーカーはどうやってジョブをタイムアウトさせる？</h4>
    <p>Timeout.timeout を使います。</p>
  </div>
  <div>
    <h4>失敗した時に再実行させたくない場合は？</h4>
    <p>Delayed::Worker.max_attempts を 1 とすれば、そのワーカーで実行される再実行しなくなります。</p>
    <p>ペイロードオブジェクトが max_attempts に応答出来れば、その値を最大試行回数とします。</p>
  </div>
  <div>
    <h4>ワーカーの名前はどう決まる？</h4>
    <p>基本的にはうまいこと決めてくれます。</p>
    <pre><code>"#{@name_prefix}host:#{Socket.gethostname} pid:#{Process.pid}" rescue "#{@name_prefix}pid:#{Process.pid}"</code></pre>
    <p>デーモンスクリプトの -p/--prefix を使ってプレフィクスを指定する事もできます。</p>
  </div>
</div>
<div>
  <h3>まとめ</h3>
  <p>自分が名前を知っている Ruby 製ジョブキューは、Delayed_job と Resque と Sidekiq の 3 つだけです。その中で Delayed_job が手軽だと考えるのは、セットアップの容易さと利用の容易さがあるからです。<p>
  <p>サービスを Rails で開発している場合、大抵は ActiveRecord を使うと思います。そうであれば、その時点で Delayed_job の環境はできあがっている様なものです。後は、Gemをインストールしてテーブルを用意したら、デーモン(ワーカー)を立ち上げるだけ。(ワーカーの運用・保守について考える必要はありますが。)</p>
  <p>delay メソッドや handle_asynchronously を使えば、既存のメソッドを簡単に遅延処理にすることが出来ます。もちろん、バックグラウンド処理専用のクラスを作り、それをキューに登録する事もできます。</p>
  <p>一方 ResqueとSidekiqは、ジョブの数が膨大なケースで役に立つのだろうという認識でいます。ほどほどの用途であれば、Delayed_job は良い選択肢だと思いますがいかがでしょうか。</p>
</div>