---
title: Rails のエラー通知を fluentd 経由で Bugsnag に送る
date: 2015-05-19 12:00 JST
authors: ff_koshigoe
tags: resume, operation
---

[![bugsnag logo](/images/2015/05/logo-bugsnag.png)](https://bugsnag.com/)

こんにちは。2月に入社して以来、とうとう勉強会の担当が回ってきた腰越です。

最近、現在進行中のプロジェクト(Rails)にて [Bugsnag](https://bugsnag.com/) というサービスを導入いたしましたので、導入までの経緯について発表させていただきました。

- Bugsnag とは？
- なぜ Bugsnag を使うのか
- Bugsnag をどう使うのか

<!--more-->

## Bugsnag とは？

Bugsnag は、アプリケーションで発生した例外の検知・診断に役立つサービスです。

![bugsnag screenshot](/images/2015/05/bugsnag-screenshot.png)

類似サービスとして、[Airbrake](https://airbrake.io/) や [Raygun](https://raygun.io/)、[Rollbar](https://rollbar.com/)、オープンソースでは Sentry([SaaS](https://getsentry.com/welcome/), [OSS](https://github.com/getsentry/sentry)) や [errbit](https://github.com/errbit/errbit) などがよく知られているのではないでしょうか。

## Bugsnag 導入に至る経緯

これまで、アプリケーションのエラー処理にて「エラーメールを送る」という対応をよく行ってきましたが、その一方で、過去の経験から「発生したエラーを通知するだけだと運用で苦労する」という問題があることも感じていました。

そこで、この問題を解決するべく、エラー情報を賢く取り回してくれるサービスの導入を検討する事にしました。

### 感じていた問題

- エラー発生の度に通知がくるので、短い間隔でエラーが連続すると通知が山積する(メール通知だとメールが遅延しかねない)
- エラー情報が通知先で保管されるので、複数人での協力作業に手間取る
- 既に対応中のため、該当箇所の通知だけを止めたい、という事は容易でない
- 通知を受けるだけなので、「対応は不要」とか「誰が対応しているか」などの状況の管理が容易でない
- エラー情報を探すのが容易でない

### そこで Bugsnag

BTS の様にエラーを管理してくれるサービスを使えば感じている問題は解消されそうだと考え、いくつかのサービスを軽く試した結果 Bugsnag の導入に至りました。

- Bugsnag はアプリケーションのエラーを検知して記録する仕組みを提供してくれる
- Bugsnag はエラーを一定のルールで束ねて管理することができる(メールで言うスレッド的な)
- Bugsnag は記録されたエラーをフィルタして一覧することができる
- Bugsnag は記録されたエラーに担当者を割り当てたり解決済みにしたりコメントを付けたりする事ができる
- Bugsnag は外部サービスと連携する事ができる
    - メールで通知することができる
    - Issue Tracker との連携(エラー発生時に GitHub issue を作ることができる)
    - Slack や PagerDuty などを使って通知を送ることができる
- Bugsnag はエラーを様子見することができる
    - あと○回発生するまで無視する
    - 一時間以内に○回発生するまで無視する
    - ○時間以内に発生するまで無視する
- Bugsnag は最初の発生でのみ通知を送る、などの調節ができる

上記機能が利用可能という点に加え、管理画面の操作感が感覚的にあったという事で、類似サービスの中から Bugsnag を選択しています。

### 余談：オープンソース系は？

Sentry や Errbit といったオープンソースのツールも利用することができますが、今回は有償サービスを使うよりも結果として運用コスト(人件費、技術的負債)が大きくなると判断して見送りました。操作感的にも合わなかったという理由もありますが。

## Bugsnag をどう使う？

今回 Bugsnag を導入するプロジェクトでは Rails を使っているため、[bugsnag/bugsnag-ruby](https://github.com/bugsnag/bugsnag-ruby) を利用します。

bugsnag-ruby の標準機能では、スレッドを使って Bugsnag への送信処理が実行されます。

### Bugsnag への送信を Fluentd に任せる

bugsnag-ruby の標準機能ではリトライなどの通信周りのフォローは行わないため、そのあたりを考慮すると何かしらの工夫が欲しくなります。そこで、Fluentd を使う事を考えました。

今回は、Rails アプリケーションから直接 Fluentd にデータを送信する形式で、Fluent を経由した Bugsnag への送信処理を実現してみました。将来的にログファイルに書き出したエラー情報を Fluentd で読み取る方式に変わるかもしれません。

#### Rails から Fluentd

bugsnag-ruby でのエラー情報送信処理を Fluentd への送信に置き換えるため、[feedforce/bugsnag-delivery-fluent](https://github.com/feedforce/bugsnag-delivery-fluent) という gem を作りました。bugsnag-ruby の設定 `Bugsnag.configuration.delivery_method` を `:fluent` とすることで使える様になります。

```rb
Bugsnag.configure do |config|
  ...
  config.delivery_method = :fluent
  # config.fluent_tag_prefix = 'bugsnag'
  # config.fluent_host = 'localhost'
  # config.fluent_port = 24224
end
```

Fluentd で受け取ったエラー情報を Bugsnag に送信するために、[feedforce/fluent-plugin-bugsnag](https://github.com/feedforce/fluent-plugin-bugsnag) を使います。

```
<source>
  type forward
</source>

<match bugsnag.deliver>
  type bugsnag

  # bugsnag_proxy_host localhost
  # bugsnag_proxy_port 8888
  # bugsnag_proxy_user user
  # bugsnag_proxy_password password
  # bugsnag_timeout 10
</match>
```

## まとめ

- エラーメールに疲れたのでエラー管理系サービスを使うことにしました
- エラー管理系サービスの中から Bugsnag を選択しました
- Bugsnag への通知は Fluentd を経由して行う様にしました
- Bugsnag の導入を決めたプロジェクトは絶賛鋭意開発中のため、運用ノウハウなどは今後機会があれば別途共有します
