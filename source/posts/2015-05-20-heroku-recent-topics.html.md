---
title: 数年ぶりに Heroku を使って感じたことなど
date: 2015-05-20 12:00 JST
authors: ff_koshigoe
tags: operation
---

![Heroku logo](/images/2015/05/heroku-logotype-horizontal-purple.png)

こんにちは。腰越と申します。

最近、数年ぶりに仕事で [Heroku](https://heroku.com/) を使う様になったので、久しぶりに使って感じたこと、Heroku で最近できる様になってうれしかった事などを書いてみたいと思います。

<!--more-->

## GitHub 連携

Heroku のデプロイ機能には GitHub 連携機能があり、GitHub にあるリポジトリから Heroku デプロイする事が可能です。

- 自動デプロイ(Automatic deploys)
- PRデプロイ(Review apps)
    - 5/19 に Pull request apps から Review apps に名称が変わった様です
    - [Heroku | Heroku Review Apps Beta](https://blog.heroku.com/archives/2015/5/19/heroku_review_apps_beta)
- 手動デプロイ(Manual deploy)

管理画面からデプロイできて便利なのですが、Rails アプリでおきまりのデプロイ後処理まで実行出来るわけではないのが残念です。PRデプロイの初回のみ、app.json の postdeploy で指定したコマンドを実行出来るのでおしいところです。

### Review apps

PRデプロイでは app.json というアプリケーションの定義ファイルのようなものを使います。このファイルに書かれている、デプロイ後処理を指定する postdeploy や、環境変数の設定、利用するアドオンの設定を使って Heroku アプリケーションが作られる仕組みになっています。

- postdeploy を書いておけば、アプリ作成時に `rake db:setup` 等を実行することができる
    - postdeploy は初回のみの実行なので、PR デプロイ実行後のコミットでマイグレーションなどが追加されていると困る
- env に環境変数を書いておけば、アプリ作成時に設定される
    - 親アプリからの継承や、作成時にランダム生成する事も可能
- addons に利用するアドオンを書いておけば、アプリ作成時に自動で登録される
    - addons にはコマンドラインオプション(--version=9.4)は書けず、PostgreSQL 9.4 がベータだった頃に困った

ボタン一つで諸々のセットアップ含めて Heroku アプリの複製が作れるので、PRレビュー用の確認環境を作ったり、実験用の動作環境を作ったりといった作業が大変手軽で気軽に行えて便利です。

### 余談：Heroku ボタン

最近、Heroku ボタンがプライベートリポジトリに対応した様ですが、当然ながらPRデプロイと違って環境変数の引き継ぎなどは行わないため、今の所役立てる場面に遭遇していません。

## free dyno

最近、dyno の新しい料金体系(public beta)が発表されました。

- [Heroku | Heroku’s Free (as in beer) Dynos](https://blog.heroku.com/archives/2015/5/7/heroku-free-dynos)

これまでの料金体系では、アプリケーションあたり 750時間分の無料 dyno 時間が貰えていたため、dyno 1 つ分までなら無料で利用する事ができました(web のみ、worker のみ、など)。

- [750 free dyno-hours per app](https://devcenter.heroku.com/articles/usage-and-billing#750-free-dyno-hours-per-app)

free dyno という新しい無料プランでは、web と worker (heroku run, Schedule 含む) の dyno を 1 つずつ無料で使える様になります。ただし、24時間のうち18時間までしか稼働できないという制限があります。

制限はありつつも、「プロジェクト初期段階でお客様に見ていただくためのプレビュー環境を手早く用意したい。」という用途でジョブキューも使える様になった事はうれしい限りです。

## 余談：docker:release

最近発表された `docker:release` は、気になりつつも触れていません。デプロイ後の後処理(`rake db:migrate` など)をカスタマイズできる仕組みだとうれしいのですが。

- [Heroku | Introducing 'heroku docker:release': Build & Deploy Heroku Apps with Docker](https://blog.heroku.com/archives/2015/5/5/introducing_heroku_docker_release_build_deploy_heroku_apps_with_docker)

## まとめ

- Review apps は便利だと思います
- free dyno でジョブキューが使える様になってうれしいです
- `docker:release`は気になりますが、まだ触れていません
- 何年経っても Tokyo リージョンはないですね
