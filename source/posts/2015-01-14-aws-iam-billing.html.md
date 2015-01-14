---
title: AWSで請求情報をIAMユーザーでも閲覧できるようにする
date: 2015-01-14 12:30 JST
authors: sugiuchi
tags: aws
---

通常、請求情報はrootアカウントでしか変更、閲覧はできませんが設定をすればIAMユーザーでもできるようになります。
エンジニアでもサーバ代がいくらかかっているか知っておくのは無駄ではないと思うので閲覧できるようにしておきたいところです。

しかしフルアクセスのままだと誰でもクレジットカードの追加や削除ができるようになってしまうので、今回はIAMユーザーが請求金額のみ閲覧できるように設定します。

<!--more-->

## 請求情報、ツールへのアクセスを許可する

そもそもIAMで設定可能にすることを許可する設定が必要です。

まずはrootアカウントでログインし、下記のように設定します。
チェックをつけたら`Update`を押します。

![Billing_Management_Console1.png](/images/2015/01/aws-iam-billing-01.png)

これでIAMでBillingのポリシーを設定できるようになります。

## IAMでポリシーを作成する

※ `AdministratorAccess` というポリシーを作成してユーザーに付与している前提に書きます。

`AdministratorAccess` は要するにフルアクセス状態です。
このままではBillingページでクレジットカードの追加削除ができてしまうので、`ViewBilling` 以外をdenyにしたポリシーを作成してユーザーに付与します。

### IAMのページを開く

![Billing_Management_Console2.png](/images/2015/01/aws-iam-billing-02.png)

### 新しくポリシーを生成する

![Billing_Management_Console3.png](/images/2015/01/aws-iam-billing-03.png)

![Billing_Management_Console4.png](/images/2015/01/aws-iam-billing-04.png)

この後、`Add Statement` -> `Next Step` -> `Apply Policy` でOK

### BillingのページでPayment Methodsが見られなくなっている

![Billing_Management_Console5.png](/images/2015/01/aws-iam-billing-05.png)

要は`ViewBilling`だけがallowになっていればいいのでポリシーの適用状態によっては上記通りでなくても問題ないです。

## ドキュメント

* https://docs.aws.amazon.com/ja_jp/awsaccountbilling/latest/aboutv2/control-access-billing.html
* https://docs.aws.amazon.com/ja_jp/awsaccountbilling/latest/aboutv2/billing-permissions-ref.html
