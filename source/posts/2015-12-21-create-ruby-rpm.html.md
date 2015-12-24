---
title: Rubyのrpmをdocker + CircleCIでGitHubに自動リリースする
date: 2015-12-21 10:45 JST
authors: tjinjin
tags: operation
---

皆様いかがお過ごしでしょうか。tjinjinです。もう師走となり、なんだかしみじみする季節ですね。

本日はRubyのrpmパッケージ作成を自動化しましたのでご紹介します！

<!--more-->

## As Is
弊社内ではこれまでRubyのrpmパッケージがリリースされるたびに有志が、手動でパッケージを作成してGitHubのreleaseページに公開するという運用をしておりました。慣れればなんてことはないのですが、初めて行う場合は若干面倒だなという感じる作業でした。フローに起こすと下記のようになります。

* Rubyのリリース後、Vagrantを使ってVMを起動する
* "rpmのビルドに"必要なファイルを修正して、Vagrantでコマンドを実行する
* ひたすら待つ
* 出来た"rpm"を適当な場所に保存しておく。
* "rpmを使用する予定の"OSの分だけ繰り返す。"弊社だとCentOS6と7"
* 作成できたら、GitHub releaseページにアップロード・タグ付け・descriptionの修正を行う
* 最後に修正したコードをコミットする（順番は前後するかもしれません）

## To Be
今回の仕組み化によって下記のことをすればパッケージを自動公開できるようになりました。

* Rubyのリリース後、2ファイルのみ修正してPRを作成する
* PR確認後、問題なければマージすると自動で公開される

手順としてもかなり簡単になったのではないでしょうか。簡単に概要だけ説明します。

## rpm自動公開までの道のり
### Step1 dockerを使ってrpmパッケージを作成する
こちらについては弊社インフラエンジニアのリーダが検証してくれました。

[rubyのRPMを作るのをDockerとCircleCIにやらせたら便利だった - critical alertのブログ](http://critical-alert.hatenablog.com/entry/2015/12/04/095601)

詳細についてはリンク先を見ていただきたいところですが、CentOS6とCentOS7のdockerイメージを起動してその中でrpmbuildを利用してrpmパッケージを作成します。rpmbuildする際にrootユーザはあまりよろしくないという話もあるので、専用のユーザを作成してbuildさせるようにしています。

### Step2 GitHub releaseページに公開する
こちらは私が個人ブログで検証をしておりました。

[CircleCIを使ってbuildしたパッケージを自動でgithub releaseに公開する - とある元SEの学習日記](http://cross-black777.hatenablog.com/entry/2015/11/12/223645)。

公開時にrpmパッケージのhash値を提示したいということがあり（Chefで利用）descriptionも弄ることができる、`github-release`というツールを採用しています。

### Step3 CircleCIを利用して自動で作成・公開する
docker内で作成したrpmパッケージは`docker volume`を使ってホストディレクトリに置いています。CircleCIにはbuildした成果物を置く`$CIRCLE_ARTIFACTS`という環境変数が用意されているので、下記のようにコンテナ起動時にsharedというディレクトリを`$CIRCLE_ARTIFACTS`をにmountさせています。

```sh
docker run -u rpmbuilder -v $CIRCLE_ARTIFACTS:/shared:rw $docker_image /bin/sh ./rubybuild.sh
```


作成された成果物をdeploymentタスクにて`github-release`を利用して、GitHubのreleaseページに公開しています。全体の流れは`circle.yml`をご覧いただければと思います。

```yml
machine:
  timezone:
    Asia/Tokyo
  services:
    - docker
dependencies:
  cache_directories:
    - ~/cache
test:
  post:
    - ./bootstrap-docker.sh 6
    - ./bootstrap-docker.sh 7
deployment:
  master:
    branch: master
    commands:
      - ./github-release.sh
```

ここで1点問題があり、`rpmbuidler`というユーザだと`docker volume`に書き込めずエラーになってしまうということがありました。こちらは`root`もしくはUIDが1000であるユーザしか書き込めないとの情報を掴みましたので、`rpmbuilder`のUIDを1000にすることで対応しました。


### Step4 冪等性を担保する
初期ベータ版だとrelease部分の冪等性が担保されておらず、基本的にないはずですが、同じバージョンを複数回リリースしてしまうとエラーが起きる問題がありました。どうしようかなと悩んでいたところM氏が秒で対応して下さいました。

```sh
...
need_to_release() {
  http_code=$(curl -sL -w "%{http_code}\\n" https://github.com/${USER}/${REPO}/releases/tag/${VERSION} -o /dev/null)
  test $http_code = "404"
}

if ! need_to_release; then
  echo "$REPO $VERSION has already released."
  exit 0
fi
...
```

## まとめ
いかがでしたでしょうか。今回は複数のエンジニアの力によって成し遂げられたので、個人的に満足度が高かったです。

## 参考
* [feedforce/ruby-rpm](https://github.com/feedforce/ruby-rpm)
* [CircleCIを使ってbuildしたパッケージを自動でgithub releaseに公開する - とある元SEの学習日記](http://cross-black777.hatenablog.com/entry/2015/11/12/223645))]
* [rubyのRPMを作るのをDockerとCircleCIにやらせたら便利だった - critical alertのブログ](http://critical-alert.hatenablog.com/entry/2015/12/04/095601))]
