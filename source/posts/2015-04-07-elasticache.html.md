---
title: ElastiCacheをCloudWatch+fluentd+Zabbixで監視する
date: 2015-04-07 14:00 JST
authors: masutaka
tags: aws, operation
---
 [![fluentd logo](/images/2015/04/fluentd-logo.png)](http://www.fluentd.org/)

ご無沙汰しております。増田でございます。

先日2日には[ゼノブレイド](http://www.nintendo.co.jp/3ds/cafj/)が発売され、今月23日には[ブレイブリーセカンド](http://www.jp.square-enix.com/second/)が発売されます。
そんな忙しい中、みなさんいかがお過ごしですか。

<!--more-->

## KyotoTycoonからElastiCacheへの移行

今まで弊社の[ソーシャルPLUS](https://socialplus.jp/)では、Railsのセッションストアとキャッシュサーバに[KyotoTycoon](http://fallabs.com/kyototycoon/)を使っていました。

しかし、KyotoTycoonはRails4でmemcachedを使うために必要な[dalli](https://rubygems.org/gems/dalli)から使えません。バイナリプロトコルをフルサポートしていないためだと思います。

そのため今週月曜日に[AWS ElastiCache](http://aws.amazon.com/jp/elasticache/)に移行しました。

KyotoTycoonは他にも以下のようなツラミがありました。

* 開発が止まっている
* KyotoTycoonが稼働するEC2インスタンスを自前で用意し、運用する必要がある
    * レプリカと合わせて2台構成
* サーバのCIも行っている都合上、rpmを作る必要がある
    * 関連記事: [Vagrantで簡単に作れる！！RubyやKyotoTycoonのrpmたち](/vagrant-rpm.html)

## ElastiCacheの構成

* EngineはRedis-2.8
* Node Typeはcache.m3.medium
* primaryとread replicaの2台構成でAvailability Zoneは別
* それぞれのNodeは1台ずつ

EngineをMemcachedではなくRedisにしたのは、read replicaを使いたかったからです。

## データの永続化

デフォルトパラメータではファイルに書き出さないため再起動したらデータは消えます。

AOF（Append-Only File）を有効にして（appendonly=yes）トランザクションログを記録すれば回避できますが、ソーシャルPLUSではそこまで繊細なデータは扱っていません。

そのため、再起動が必要な時はread replicaをPromoteすることにしました。

## ElastiCacheの監視

本番環境で動かすためには監視はかかせません。

ソーシャルPLUSでは当初からZabbixを使っており、KyotoTycoonの時は監視用のスクリプトを用意してZabbixに登録していました。

ElastiCacheではCloudWatchが使えるので、fluentd経由でZabbixに送信することでシンプルかつ既存の監視と馴染ませることが出来ました。

![watch elasticache](/images/2015/04/watch-elasticache.png)

ちなみにEC2インスタンス上で[fluent-plugin-zabbix](https://rubygems.org/gems/fluent-plugin-zabbix)を使うためには、一工夫必要でした。付録の「fluent-plugin-zabbix使用時のworkaround」に記載しました。

## fluentd自体の監視

fluentdが落ちると困るので監視を追加しました。

fluentd付属の[Monitoring Agent](http://docs.fluentd.org/articles/monitoring)を有効にし、Zabbixがポーリングしています。

![watch fluentd](/images/2015/04/watch-fluentd.png)

## まとめ

* ElastiCacheを監視するために、CloudWatchからメトリクスを取得し、fluentd経由でZabbixに転送した
* fluent-plugin-zabbixをEC2上で使う時は、workaroundが必要
* fluentd付属のMonitoring Agentを有効にし、Zabbixでfluentdを監視した

## 付録

### fluentdの設定ファイル

今回の設定内容です。

```
#
# ElastiCacheの監視設定
#

<source>
  type        cloudwatch
  aws_key_id  <AWS_ACCESS_KEY_ID>
  aws_sec_key <AWS_SECRET_ACCESS_KEY>
  cw_endpoint monitoring.ap-northeast-1.amazonaws.com

  tag              cloudwatch.elasticache
  namespace        AWS/ElastiCache
  statistics       Maximum
  metric_name      CPUUtilization,SwapUsage,FreeableMemory,NetworkBytesIn,NetworkBytesOut,BytesUsedForCache,CacheHits,CacheMisses,CurrConnections,CurrItems,Evictions,GetTypeCmds,KeyBasedCmds,NewConnections,Reclaimed,ReplicationLag,SetTypeCmds,StringBasedCmds
  dimensions_name  CacheClusterId
  dimensions_value production-001
  period           60
  interval         60
</source>

<match cloudwatch.elasticache>
  type           zabbix
  zabbix_server  10.0.40.10
  host           ElastiCache
  name_keys      CPUUtilization,SwapUsage,FreeableMemory,NetworkBytesIn,NetworkBytesOut,BytesUsedForCache,CacheHits,CacheMisses,CurrConnections,CurrItems,Evictions,GetTypeCmds,KeyBasedCmds,NewConnections,Reclaimed,ReplicationLag,SetTypeCmds,StringBasedCmds
  add_key_prefix aws.elasticache
</match>

#
# fluentd自体の監視設定
#

<source>
  type monitor_agent
  bind 0.0.0.0
  port 24220
</source>
```

### fluent-plugin-zabbix使用時のworkaround

今回のfluentdはEC2上で動いていますが、fluent-plugin-zabbixが依存する[zabbix gem](https://rubygems.org/gems/zabbix)がうまく動作しませんでした。

[PullRequestを送りました](https://github.com/mhat/zabbix-rb/pull/4)が、すでにメンテされていないようでマージされるか分かりません。

そのため修正したzabbix gemを使うChefのレシピにしました。

これがtd-agentとpluginをインストールするためのレシピです。CentOS6で動作確認しています。CentOS7でも動くと思います。

```
include_recipe 'td-agent'

conf_file = node['sp-td-agent']['conf_file']

return unless conf_file

directory '/etc/td-agent/conf.d'

execute 'Add @include directive' do
  command 'printf "\n@include conf.d/*.conf\n" >> /etc/td-agent/td-agent.conf'
  not_if 'fgrep "@include conf.d/*.conf" /etc/td-agent/td-agent.conf'
  notifies :reload, 'service[td-agent]'
end

cookbook_file "/etc/td-agent/conf.d/#{conf_file}" do
  notifies :reload, 'service[td-agent]'
end

include_recipe 'sp-td-agent::workaround_zabbix_gem'

%w(fluent-plugin-cloudwatch fluent-plugin-zabbix).each do |gem|
  gem_package gem do
    gem_binary '/opt/td-agent/embedded/bin/fluent-gem'
    notifies :reload, 'service[td-agent]'
  end
end
```

`include_recipe 'td-agent'` ではこちらのレシピが実行されます。

```
execute 'Install td-agent' do
  # See http://docs.fluentd.org/articles/install-by-rpm
  command 'curl -L http://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh'
  not_if 'rpm -q td-agent'
end

service 'td-agent' do
  action [:enable, :start]
  supports restart: true, reload: true, status: true
end
```

`include_recipe 'sp-td-agent::workaround_zabbix_gem'` がzabbix gemのworkaroundです。

```
version = '0.4.1'
gem_file = "zabbix-#{version}.gem"
gem_fullpath = "/var/tmp/#{gem_file}"

remote_file gem_fullpath do
  source "https://github.com/masutaka/zabbix-rb/releases/download/v#{version}/#{gem_file}"
  checksum '9d6f8c5bc1f8019dca351c056110b5be16a82bd3f5c84347b0d7a2075e93a5ed'
end

gem_package 'zabbix' do
  gem_binary '/opt/td-agent/embedded/bin/fluent-gem'
  source gem_fullpath
  notifies :restart, 'service[td-agent]'
end
```

## 参考情報

* https://github.com/yunomu/fluent-plugin-cloudwatch
* https://github.com/fujiwara/fluent-plugin-zabbix
* [Redis のパラメータ - Amazon ElastiCache](http://docs.aws.amazon.com/ja_jp/AmazonElastiCache/latest/UserGuide/CacheParameterGroups.Redis.html)
* [Amazon ElastiCache のディメンションおよびメトリックス - Amazon CloudWatch](https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/DeveloperGuide/elasticache-metricscollected.html)
