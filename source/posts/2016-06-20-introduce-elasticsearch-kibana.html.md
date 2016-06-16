---
title: フィードフォースにおける Elasticsearch+Kibana の導入事例
date: 2016-06-20 13:00 JST
authors: masutaka
tags: aws, operation
---
最近遅ればせながら光の戦士になった増田です。サボり癖がなかなか直りません。

さて、この度 [Elasticsearch](https://www.elastic.co/jp/products/elasticsearch) と [Kibana](https://www.elastic.co/jp/products/kibana) の社内事例を作ることが出来ましたので、興奮のあまりお伝えします。

<!--more-->

## ずっと導入したかった

2014 年 3 月に中途で入社して以降、導入したかったものの 1 つが Elasticsearch でした。[個人ではすでに導入しており](https://masutaka.net/chalow/2014-12-14-1.html)、効果を実感できていたためです。

その前段である fluentd の社内初事例が 2015 年 4 月のこちらの記事。気がつけば社内の他のプロジェクトにも導入が進んでいました。

[ElastiCacheをCloudWatch+fluentd+Zabbixで監視する | feedforce Engineers' blog](http://tech.feedforce.jp/elasticache.html)

ところで私は先月から [DF PLUS](https://dfplus.feedforce.jp/) というサービスにフルコミットし、主にエラー管理やログ基盤などを整備しています。

エラー管理については、[弊社ではもうお馴染みとなった Bugsnag](http://tech.feedforce.jp/rails-fluent-bugsnag.html) で整備しました。

実はログ基盤は特に求められていませんでした。でも個人的には、絶対ログ基盤があるべきでサービスの可視化も絶対に必要という、根拠のない信念を持っていました。今回導入して効果を実感できているので、本当にうれしく思っています。

## CloudWatch Logs に送っていた

これまで DF PLUS では、Rails の Production ログを fluentd 経由で CloudWatch Logs に送っていました。

CloudWatch Logs はお手軽なのですが、このような問題もあります。

* ログの保存期間が 2 週間
* 柔軟にグラフを作ることが出来ない
* AWS の UI がアレで見ようという気にならない

特に 2 週間縛りが致命的で、中長期的なメトリクスを取得することが出来ません。

## AWS Elasticsearch を導入した

そういう状況もあり、虎視眈々と導入を狙っていました。[去年の 10 月に AWS Elasticsearch がリリース](http://aws.typepad.com/aws_japan/2015/10/amazon-elasticsearch-service.html)されたときはうれしかったですね。

導入は[公式ガイド](https://aws.amazon.com/jp/elasticsearch-service/)に加え、クラスメソッドさんのこちらの記事を参考にしました。

[AWS再入門 Amazon Elasticsearch Service編 ｜ Developers.IO](http://dev.classmethod.jp/cloud/aws/cm-advent-calendar-2015-getting-started-again-amazon-es/)

機能は相当制限されています。例えば本来の elasticsearch.yml にいくつも設定できるのに、AWS ではたったの 2 つです。

* [rest.action.multi.allow\_explicit\_index](https://www.elastic.co/guide/en/elasticsearch/reference/1.5/url-access-control.html)
* [indices.fielddata.cache.size](https://www.elastic.co/guide/en/elasticsearch/reference/1.5/index-modules-fielddata.html)

他にもバージョンは 1.5.2 固定だったり（2016 年 6 月現在の最新は 2.3.3）、VPC 内に作ることが出来ない等の制限があります。

今回はこれらが導入の障壁にならなかったため、AWS の Elasticsearch service を採用しました。

[本家の Elastic さんもホスティングサービスを出してます](https://www.elastic.co/cloud)ので、検討してみるのも良いかもしれません。

## 導入してよかったこと

* サービスの現在を可視化出来る
* サービスの現在のログを、サーバにログインすることなく見られる
* 複数サーバのログを横串で検索できる
* データを可視化出来る

そこまで大量のログではないとは言え、個人サーバよりもいろいろなデータを扱えるのは面白いですね。まだまだこれからですが、エンジニア以外の方々も巻き込んでいけたらなと思っています（チームのエンジニアには相当受けが良かったw）。

![Kibana](/images/2016/06/kibana.png)

## まとめ

* ログ基盤は絶対に必要
* データを可視化すると楽しい
* CloudWatch Logs は甘え

## 付録

### アクセスポリシーの Tips

今回は Production サーバから [fluent-plugin-aws-elasticsearch-service](https://github.com/atomita/fluent-plugin-aws-elasticsearch-service) 経由で AWS Elasticsearch にログを送っています。

[この時、AWS の Credentials 情報が必要です。](https://github.com/atomita/fluent-plugin-aws-elasticsearch-service/blob/v0.1.4/lib/fluent/plugin/out_aws-elasticsearch-service.rb#L38)Production サーバの IP アドレスをアクセスポリシーに加えても、意味がありませんのでご注意下さい。EC2 インスタンスの場合は、Elasticsearch のパーミッションを持った IAM Role を付与すると良いでしょう。

今回は社内から Kibana でアクセスするための、IP アドレス制限ポリシーのみ設定しました。

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:ap-northeast-1:012345678901:domain/domainname/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [
            "IPアドレス1",
            "IPアドレス2"
          ]
        }
      }
    }
  ]
}
```
