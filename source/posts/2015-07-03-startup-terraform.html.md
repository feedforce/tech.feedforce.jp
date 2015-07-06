---
title: terraformを使ってAWS環境を構築する
date: 2015-07-03 11:52 JST
authors: tjinjin
tags: terraform, aws, operation
---
![terraform logo](/images/2015/07/terraform-logo.png)

お久しぶりです。tjinjinです(╹◡╹)

最近じめじめしていますね。梅雨あけると夏ですよ！！夏アニメが始まりますよ！！
ということで、PV見た感じの私のおすすめは六花の勇者です！”りっか”ではなく”ろっか”です！

<!--more-->

## AWS環境のコード化

弊社ではAWS環境の構築を管理コンソールでの温かみのある作業やRakeTaskで行ってきましたが、サービスを新規で立てるのに時間がかかるという課題があり、AWS環境もコード化したいという思いがありました。インフラチーム内で検討した結果、 <s>名前がかっこいい</s> コードが読みやすいということで一部サービスでterraformを採用し始めています。

terraformを使って行く中で、何点か壁にぶち当たったので情報共有できればと思います。

## terraformとは？

一言で表すとインフラ構成をコード化することのできるツールというところでしょうか。みんな大好きHashicorp社のツールですね。今回の記事ではAWSを主に使いますが、HerokuやDigitalOceanなどでも利用でき汎用性の高いオーケストレーションツールといえるのではないでしょうか。


## 弊社での使い方

弊社内ではterraformを使う上で下記のような運用にしています。

### terraform applyは手動で実行する
弊社ではCircleCIを使ったサーバCIを行っていますが、terraformではまだ運用実績がないためPRを確認した後に手動実行するようにしております。ゆくゆくは自動で実行できるようにしていきたいところです。

### tfstateファイルはs3で共有する
複数人で開発を行うときに問題となるのが、tfstateファイルの扱いです。各人のローカルにあるtfstateファイルが同期されていないと、同じtfファイルを使っていても、違う環境ができあがる可能性があります。v0.5.0からs3上にtfstateファイルを保存し、そこを参照する設定ができるようになりました。Atlasやgithub上での共有も検討したのですが、Atlasは将来的な有料化のリスクを鑑み、github上ではそもそも厳しいということでs3を選択しました。

```
$ terraform remote config -backend=S3 -backend-config="<s3_bucket_name>" -backend-config="key=<tfstate_name>"
```

### tfファイルはひとつのファイルにする
弊社内で1ヶ月くらい前に話あったのですが、現在の運用では下記のようなフォルダ構成にしております。エンジニア間でも意見がわかれる所なのですが、一旦１ファイルでといことにしています。たぶん変更します。

```
$ tree -a
.
├── production
│   ├── .envrc
│   ├── .terraform
│   │   ├── terraform.tfstate
│   │   └── terraform.tfstate.backup
│   ├── main.tf
│   └── terraform.tfvars
└── stage
    ├── .DS_Store
    ├── .envrc
    ├── .terraform
    │   ├── terraform.tfstate
    │   └── terraform.tfstate.backup
    ├── main.tf
    └── terraform.tfvars

```

AWSの認証情報は.envrcに保存し、direnvを使っています。当初tfvarsファイルに設定するようにしていたのですが、各人のIAMを使っていこともあり、構成管理するものでもないので、環境変数の方が楽ではということになりました。


## 利用していく中でぶつかった問題

### terraformで環境を構築した後に管理コンソールで環境を変更してしまい、`terraform plan`叩いたときに差分が出ました。どうすれば？

*弊社インフラチーム内では禁止事項です。*

仮に行った場合は、反逆罪として牢獄に打ち込まれるレベルです（嘘です）。

tfファイルと実際の環境に差分がある状態でapplyするとtfファイルの状態に修正しようと動きます。tfファイルだけだと`terraform plan`時に差分が出てしまうので、tfstateも修正する必要があります。

+ tfファイルを最新の環境に合わせて修正する
+ tfstateファイルも最新の環境に合わせて修正する
+ `terraform plan`を実行し、差分が出ていない状態にする

ここまでやれば大丈夫です。


### terraformで作った、security groupの名前が間違ってた。正しい名前に変えたいんだけど、もうサーバ立ってるけどどうなるの？

*applyできません。*

terraformはapply時は依存関係をうまく処理してくれますが、変更などによって環境を一時破壊する際には安全に倒す設計のため、依存関係があると削除できません。今回のケースではSG内にサーバ構築されており、依存関係がある状態になりますのでそこを解消するために、SGグループからサーバを除外してあげる必要があります。

手動で行うのが嫌でしたので、applyだけでやろうとすると下記の手順になりました。

+ tfファイルのサーバに関する部分をコメントアウトしてapplyする（サーバが削除されます）。
+ tfファイルでSGの名前を変更してapplyする（SGが一度破棄・再構築されます）。
+ サーバ部分のコメントアウトを外しapplyする

コレジャナイ感が非常にありますね(；・∀・）

### terraformで立てたサーバがインターネットにアクセスできないんだけど！！前は出来たのにどうなってるの（怒）

*terraformのバージョンアップによる影響です。*私のせいではないので、怒らないで下さい＞＜

直接の原因としては、SGのoutbound設定がされておらず外に通信できないためです。AWSの初期設定ではoutboundの設定がされるのですが、terraformの仕様がかわり、v0.5.0以降ではデフォルトの設定が削除されるようになりました[link](https://github.com/hashicorp/terraform/blob/master/CHANGELOG.md#050-may-7-2015)。従って、v0.5.0以降で作成する場合は下記のように`egress`の設定が必要です。

```
resource "aws_security_group" "web" {
    name = "test"
    description = "Used in the terraform"
    vpc_id = "${aws_vpc.main.id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
```


## まとめ
まだまだ、発展途上のプロダクトのため変更を追うのが大変です。運用の情報なども少ないので、情報交換させて下さい＞＜次の記事は、terraformingを使って既存環境をコード化するって記事を書きたいと思っています。（未定）
