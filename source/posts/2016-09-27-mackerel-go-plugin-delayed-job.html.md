---
title: Go で Mackerel の delayed_job plugin を作った
date: 2016-09-27 15:00 JST
authors: masutaka
tags: operation
---
増田です。椅子を新調したら腰痛が始まりました。でも元気です。

さて、少し前に Go で Mackerel の delayed\_job plugin を作りました。

<!--more-->

<!-- textlint-disable -->
<a class="embedly-card" href="https://github.com/masutaka/mackerel-plugin-delayed-job-count">masutaka/mackerel-plugin-delayed-job-count</a>
<script async src="//cdn.embedly.com/widgets/platform.js" charset="UTF-8"></script>
<!-- textlint-enable -->`

## なぜ作ったか？

最近、私が関わっているソーシャルPLUSで、新しいサービスを作り始めました。今までは Zabbix で監視していたのですが、稼働用のサーバやある意味特殊スキルが必要で、導入すべきか悩んでいました。そういった事情から、今回は [Mackerel](https://mackerel.io/) を採用したのが事の発端です。

このサービスでは [delayed_job](https://rubygems.org/gems/delayed_job) が動いています。delayed\_job の監視は大きく 2 つが必要です。

1. プロセス数の監視
2. Job Queue の監視

1 については Ruby で書いた Mackerel plugin を作りました。pgrep を使ってプロセス数をカウントする素朴なスクリプトです。

```ruby
#!/usr/bin/env ruby

if ENV['MACKEREL_AGENT_PLUGIN_META'] == '1'
  require 'json'

  meta = {
    graphs: {
      'delayed_job' => {
        label: 'delayed_job processes',
        unit: 'integer',
        metrics: [
          {
            name: 'processes',
            label: 'processes'
          }
        ]
      }
    }
  }

  puts '# mackerel-agent-plugin'
  puts meta.to_json
  exit 0
end

process_count = %x(pgrep -fc '^delayed_job').chomp

puts [ 'delayed_job.processes',  process_count, Time.now.to_i ].join("\t")
```

2 も当初は Ruby で書く予定でしたが、以下の理由により Go で書くことにしました。

* システムに mysql2 などの Gem をインストールする必要があり、Chef レシピの依存が増えてしまう
    * そういう意味では 1 も Ruby との依存が出来ている
* 業務で Go を書いてみたい。そういう文化を作りたい

## どのように作ったか？

初めは [monochromegane/mackerel-plugin-delayed-job-count](https://github.com/monochromegane/mackerel-plugin-delayed-job-count) をそのまま使う予定でした。

でも、取りたいメトリクスや、設定の渡し方がそれなりに違ったため、あれこれいじっていたら別物になってしまいました。

## 何ができるか？

現在は MySQL のみ対応しています。PostgreSQL 等への対応も難しくないようなので、いずれ対応するかもです。

今回の masutaka/mackerel-plugin-delayed-job-count は以下のメトリクスを Mackerel に送信します。実際の SQL は発行回数を減らすため、若干違います。

* Processed Job Count
    * 直近 1 分で処理したジョブ数
    * `SHOW TABLE STATUS LIKE 'delayed_jobs'` で取得した `Auto_increment` を -1 して、差分を Mackerel に送信
* Queued Job Count
    * 現在キューに溜まっているジョブ数
    * `SELECT COUNT(*) FROM delayed_jobs WHERE failed_at IS NULL AND locked_by IS NULL`
* Processing Job Count
    * 現在処理中のジョブ数
    * `SELECT COUNT(*) FROM delayed_jobs WHERE failed_at IS NULL AND locked_by IS NOT NULL`
* Failed Job Count
    * 失敗したジョブ数
    * `SELECT COUNT(*) FROM delayed_jobs WHERE failed_at IS NOT NULL`

参考までに monochromegane/mackerel-plugin-delayed-job-count は以下のメトリクスを Mackerel に送信します。

* Job Count
    * 現在キューに溜まっている、または処理中のジョブ数
    * `SELECT COUNT(id) FROM delayed_jobs`
* Error Job Count
    * 失敗したジョブ数
    * `SELECT COUNT(id) FROM delayed_jobs WHERE failed_at IS NOT NULL`

## どのように使うか？

macOS と Linux 用のバイナリを GitHub にリリースしています。

https://github.com/masutaka/mackerel-plugin-delayed-job-count/releases

例えばこのような Chef レシピを書けば、/usr/local/bin/mackerel-plugin-delayed-job-count としてインストール出来ます。Ruby スクリプトと違って、レシピに依存関係が出来なくて良いですね。

```ruby
remote_file '/usr/local/bin/mackerel-plugin-delayed-job-count' do
  version = 'v0.0.1'
  checksum = 'db8c1460da2f393b76a3717ed39d036d1cea3445e6b65557654d81cad217ffc1'

  source "https://github.com/masutaka/mackerel-plugin-delayed-job-count/releases/download/#{version}/mackerel-plugin-delayed-job-count_linux_amd64"
  checksum checksum
  mode 0755
end
```

あとは /etc/mackerel-agent/mackerel-agent.conf に以下を追記し mackerel-agent を reload すれば、Mackerel への送信が始まります。

```
[plugin.metrics.delayed_job_count]
command = "/usr/local/bin/mackerel-plugin-delayed-job-count -dsn='DSN'"
```

DSN は AWS であれば `id:password@tcp(your-amazonaws-uri.com:3306)/dbname` といった書式です。詳しくは https://github.com/go-sql-driver/mysql/#dsn-data-source-name をどうぞ。


## 悩んでいること

* 公式の [mackerelio/mackerel-agent-plugins](https://github.com/mackerelio/mackerel-agent-plugins) に PR を出すべきか
    * テストを書いていない
    * delayed\_job で必要なメトリクスは用途によって違いそう。PR を出す前にオプションで指定可能にすべきか
* 社内の Mackerel plugin が複数のリポジトリに散らばってきた
    * 少なくとも Ruby スクリプトくらいは１つのリポジトリにまとめようか

## まとめ

* Go 使えて満足！
* 要望等あれば GitHub の [Issue](https://github.com/masutaka/mackerel-plugin-delayed-job-count/issues) や [PR](https://github.com/masutaka/mackerel-plugin-delayed-job-count/pulls) に挙げて下さい！
