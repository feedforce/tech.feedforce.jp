---
title: roadworkerを使ってRoute53を管理する
date: 2015-09-10 16:30 JST
authors: tjinjin
tags: aws, infrastructure, operation
---

こんにちは。tjinjinです。ついにMGSが発売されましたね！弊社内の一部で話題になっています！
さて、本日は弊社内で利用を始めたroadworkerというツールについてご紹介させていただきます。

<!--more-->

## 背景
弊社では社内にBINDでDNSサーバを立てており、各ドメインのネームサーバをそこに向けるようにしていました。ただ、BINDのセキュリティアップデートの作業コストの増加があり、自前運用をやめるため、AWSのサービスであるRoute53に移転を検討しました。そのうえで、移転後のレコードの管理をコードで行いたいという思いがありましたので、roadworkerを導入することにしました。

## roadworkerとは
[roadworker](https://github.com/winebarrel/roadworker)とは、Route53を管理できるツールで、既存の設定からのエクスポート機能など便利な機能が揃っているツールです。gemになっており、気軽に利用できます。

## roadworkerを使うメリット
* PRベースで設定の変更ができ品質の向上につながる
* エクスポート機能を使うことで既存のレコードを簡単に設定ファイルに落とすことができる
* 設定ファイルが間違っていないか判断するための`--dry-run`機能がある
* 振る舞いのテストが付属しており、テストも簡単に実行できる

様々なメリットを書きましたが、エクスポート機能が一番便利かもしれません。

## 実際に使ってみる
### 準備
#### roadworkerを導入する
roadworkderはgemなので、Rubyがあれば`$ gem install roadworker`で導入できます。

#### direnvを使ってAWSの環境変数を用意する
AWSにアクセスするのでcredencialの情報が必要です。引数としても渡せるようですが、direnvを使っています。

```
$ export AWS_ACCESS_KEY_ID=XXX
$ export AWS_SECRET_ACCESS_KEY=YYY
```

### AWSのレコードをRoutefileにエクスポートする

既存のレコードの情報をエクスポートしてみます。

```
$ bundle exec roadwork -e -o Routefile
```
-e：エクスポート
-o：出力先ファイル

```
$ bundle exec roadwork -e --split
```
--split：Hosted_zone毎に分割して管理する

最初の書き方だとそのアカウントに紐づくレコードを全て１つのファイルに出力してしまうので、レコード数が多いと若干見辛いです。そこで、`--split`オプションが用意されており、Hosted_zone毎に設定ファイルを分けることができます。

### roadworkerを使ったレコード適用する
#### レコードを修正する

追加したいhosted_zoneにレコードを追加します。

```
hosted_zone "example.jp." do
  rrset "example.jp.", "A" do
    ttl 300
    resource_records(
      "192.168.1.2"
    )
  end
end
```

今回は基本的なAレコードだけですが、他にもhealthcheckやfailoverの機能もあるようです。roadworkerのリポジトリにサンプルがあるので、ご確認いただければと思います。



#### レコードの設定テストをする

`--dry-run`オプションを使うことで、実際には適用されずsyntaxのチェックができます。

```
$ bundle exec -a --dry-run
Apply `Routefile` to Route53 (dry-run)
Create ResourceRecordSet: example.jp  (dry-run)
No change
```
このように何が作成されるかなどがわかるので、非常に便利です。（実際には色がついています）

#### レコードを適用する

実際にレコードを追加するには`-a`オプションを利用します。

```
$ bundle exec roadwork -a
Apply `Routefile` to Route53
Create ResourceRecordSet: example.jp A
```

#### レコードの振る舞いのテストをする
レコード適用後、本当にDNSレコードが引けるかテストしてくれるようです。

```
$ bundle exec roadwork -t
............F.........................................................................................
example.jp. TXT:
  expected=v=spf1 include:example.jp ~all(60)
    actual=
    102 examples, 1 failure)
```

上記はイメージになりますが、テスト結果も見やすいです。ただ反映後キャッシュの影響ですぐに切り替わらないこともあります。そういう場合はnameserverを指定することができます。

```
$ bundle exec roadwork -t --nameservers ns-xxx.awsdns-xx.com
$ bundle exec roadwork -t --nameservers ns-xxx.aws.dns-xx.com --nameservers ns-yyy.aws.dns.yy.com
```

こうすることで設定値が正しく引けているか確認が可能です。複数のnameserverを指定することも可能です。

### 注意点
同じレコードへの変更が二重で書いてある場合は、後勝ちになります。

```
hosted_zone "example.jp." do
  rrset "example.jp", "TXT" do
    ttl 60
    resource_records(
      "\"192.168.1.6\""
    )
  end

  rrset "example.jp", "TXT" do
    ttl 60
    resource_records(
      "\"192.168.1.5\""
    )
  end
end

```

となっている場合、実際に適用されるのは192.168.1.5のみでした。複数レコードを設定したい場合は下記のようにする必要があります。

```
hosted_zone "example.jp." do
  rrset "example.jp", "TXT" do
    ttl 60
    resource_records(
      "\"192.168.1.5\"",
      "\"192.168.1.6\""
    )
  end
```

## 感想
roadworkerを使うことでDNSレコードの管理が格段にしやすくなりました。振る舞いのテストも行える点が非常によかったです。
DNS周りの課題としては、ドメインの管理をAWSではなく他のリセラーで行っているため、ネームサーバの設定変更作業が大変な点です。どこかのタイミングでドメインの移行も検討したいと考えています。


## 参考資料
* https://github.com/winebarrel/roadworker
