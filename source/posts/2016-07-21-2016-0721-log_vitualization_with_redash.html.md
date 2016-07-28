---
title: Bigquery + Re:dashを使ったログの可視化
date: 2016-07-21 14:30 JST
authors: tjinjin
tags: operation
---

お久しぶりです。tjinjinです。
夏アニメも始まり力強く生きています！

今回は、私が所属しているチームでRe:dashを導入しましたので、そのお話をしたいと思います。

<!--more-->

## これまでのログの取扱い
そもそも最初はBigqueryにすらログを置いておらず、ログの確認と言えばサーバにログインして確認するという形でした。その後fluentdを使ってS3に送ったり、Biqqueryに送るようにしていきました。Bigqueryに送ることでログを横断的に見れるため障害調査などが楽にはなったのですが、そこで終わっていました。せっかくログがあるにも関わらず可視化ができていなため、サービスの利用状況が見えづらいものでした。
そこで弊社増田が他プロジェクトで[kibanaを導入している話](http://tech.feedforce.jp/introduce-elasticsearch-kibana.html)を聞き、何かないかと探していたところBigqueryをデータの置き場として利用できるRe:dashの存在を知り、今回導入にいたりました。

## Re:dashの導入方法
Re:dashを簡単に導入するにはAMIが用意されているので、Terraformで簡単に構築ができます。

```
resource "aws_instance" "redash" {
    ami = "ami-78967519"
    instance_type = "t2.micro"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${aws_security_group.redash.id}"]
    subnet_id = "${aws_subnet.public.0.id}"
    root_block_device {
        delete_on_termination = "true"
    }
    tags {
        Name = "${var.stage}-redash"
        Project = "${var.project_name}"
        Stage = "${var.stage}"
        Role = "redash"
        Group = "common"
        Created = "terraform"
    }
}

```

これだけで簡単に起動できるので、まずは導入してみることをおすすめします。

実際にどんなものなのか知りたい方はデモが公開されているので一度触ってみるとよさそうです。
[demo](https://demo.redash.io/)

## Re:dashの使い方
### データソースを追加する
Re:dashで利用するデータを指定します。Re:dashはデータソースの対応範囲が広いため、既存のデータ基盤をそのまま利用も可能です。

- Amazon Redshift
- Bigquery
- PostgreSQL
- MySQL
- TresureData

などがあります。詳しくはこちら。[Supported Data Sources — Re:dash documentation](http://docs.redash.io/en/latest/datasources.html)

Bigqueryの場合は、事前にサービスアカウントの鍵を取得しておき、それを指定するだけで可能です。

### クエリを発行する
まず可視化したいデータのクエリを発行します。クエリ自体はデータソースに応じたSQLなどを発行します。Bigqueryであれば、Bigqueryで対応しているSQLが発行可能です。

### ダッシュボードにグラフを追加する
クエリを発行したらデータの可視化を行います。Re:dashでは様々なデータの可視化方法があり、必要に応じて適切な可視化を行う必要があります。

可視化のタイプは以下のとおりです。

- Boxplot
- Chart
- Cohort
- Counter
- Map
- PivotTable

この中でPivotTableが便利で、動的にカラムを指定することができます。例えばエンジニアが基本的なクエリを発行したうえで、マーケ担当者などが自分で好きなデータをD&Dで分析することが可能です。うまく説明ができないので気になる方はお試しいただければと...。


## 細かいTips

- amiの中身はnginxなので設定を追加すればhttps化が簡単にできます
- 公式botを使ったslack連携も可能です

## 今後の課題
現在私を含む一部のメンバーを中心にデータの分析の基礎として統計学の勉強などを始めています。ソーシャルゲームなどの業界ではデータ分析専門の方もいらっしゃると思いますが、我々の規模ではそこまでというところもあるので興味あるメンバーで進めているところです。
実際にデータを見れるようになったとしても、そのデータをどう分析するか?が一番大切なところなので、そのあたりをしっかりやっていきたいと思います。
