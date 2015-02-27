---
title: このブログはGitHub Pages＋CircleCIで運用しています
date: 2015-02-27 00:00 JST
authors: tmd45
tags: resume
---

[前回の記事](http://tech.feedforce.jp/wordpress-to-middleman.html) からだいぶ間が開いてしまいましたが、再びこのブログの移行のお話です。

WordPress から Middleman への移行に伴って、記事の構成管理やホスティング、デプロイについても検討して、現在は以下のようなものを使って運用しています。

* [GitHub Pages](https://pages.github.com/)
* [CircleCI](https://circleci.com/)
* [Heroku](https://www.heroku.com)（staging 環境として利用）

<!--more-->

記事の執筆とレビュは、GitHub の Pull Request 機能を使うようになりました。これまでは WordPress 上の慣れないエディタで書くのが嫌だったり、書いた記事を非公開の状態でレビュしてもらうのに地味〜に手間がかかったりと、執筆のモチベーションを下げる要因がいろいろあったのですが、普段から開発で利用しているPRのしくみを取り入れたことで、開発チームではやりやすい方法に向かえたのではないかと思っています。<s>まぁその割に記事数は増えていませんね（笑）</s>

## GitHub Pages にホスティング

Middleman で構築したブログの運用として同様の組み合わせで、GitHub Pages にホスティングし、TravisCI で自動デプロイを行っているケースは多く拝見しました。このブログの構築でも大変参考にさせていただきました。

これもずいぶん時間が経ってしまいましたが、社内勉強会にて、同様の環境を利用して自分の個人サイトを運用している話を発表しましたので、基本部分についてはスライドでご紹介させていただきます。

<iframe src="//www.slideshare.net/slideshow/embed_code/45157414" width="595" height="485" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe> <div style="margin-bottom:5px"><a href="//www.slideshare.net/tmd45/20140822-fftt-tmd45middleman" title="Middlemanで個人ページを作っている話" target="_blank">Middlemanで個人ページを作っている話</a></div>

スライドでは、GitHub Pages の機能でも "User Page" という機能を利用した方法について発表しました。このブログではブランチ構成が異なる "Project Page" の機能を利用して、`gh-pages` ブランチをサイト公開用のブランチとして利用する方法を採用しています。

## CircleCI でデプロイ

個人では TravisCI を利用していましたが、社内では CI ツールとして CircleCI の利用が広まってきたのでそちらに乗り換えました。CI ツールの設定ファイルに書く内容はどちらもだいたい同じで、CircleCI では以下のようにしています。

```yaml
# circle.yml
general:
  branches:
    ignore:
      - gh-pages

machine:
  timezone: Asia/Tokyo

dependencies:
  pre:
    - npm install -g bower
    - bower install

test:
  override:
    - bundle exec middleman build

deployment:
  publish:
    branch: master
    commands:
      - git config --global user.name "circleci"
      - git config --global user.email "circleci@feedforce.jp"
      - bundle exec middleman deploy
```

ポイントは、以下のような部分です。

* 公開用ブランチである `gh-pages` は処理対象から除外
* CircleCI の test は `middleman build` で代用
* `middleman-deploy` gem を導入し、デプロイを設定＋ワンラインで解決

これで、トピックブランチはすべてtestまで実行され、`master` ブランチにマージされたものは自動的に `gh-pages` ブランチにデプロイされます。

ただしこのままだと、 `gh-pages` ブランチにコミットされたものを CircleCI が無視することができず、おかしなデプロイが走ってしまいます。これを防止するために Middleman の source ディレクトリのなかに、build後に `gh-pages` ブランチ用の circle.yml ファイルが残るように、以下のファイルを配置します。

```yml
# source/circle.yml
general:
  branches:
    ignore:
      - gh-pages
```

また、CircleCI では test が無いと警告が出てしまうため `middleman build` を実行していますが、実際のところこれはかなり無駄なことをしています。CircleCI はいくつかのフレームワークを判断して、とくに設定などを書かなくても[自動で適当な compile などを実施してくれます](https://circleci.com/gh/feedforce/tech.feedforce.jp/157)。Log を見ると、build コマンドが2回実行されているのがわかります。

これをもっと良さげに解決する方法はいくつかあります。test 内でコマンドの実行結果が正常終了と判断されるようにすれば良いです。ただ今回はいちおうのテストとして「静的ファイルが build できること」を確認するものとして、この記述を残しました。こじつけですね。

## まとめ

導入した `middleman-deploy` gem の設定やその他設定、実際のPRの様子は、このブログのリポジトリで見ることができます。何かのご参考になれば幸いです。

* [feedforce/tech.feedforce.jp](https://github.com/feedforce/tech.feedforce.jp)

最近では [Tachikoma.io](http://tachikoma.io/) を利用した[自動 bundle update も行うようになりました](https://github.com/feedforce/tech.feedforce.jp/pull/60)。
春には Middleman v4 のリリースもあるし楽しみです。[硝煙にまみれたゆるふわフロントエンジニア氏](http://tech.feedforce.jp/author/dkimura/)の関心は別のフレームワークに移っているようですが…それはそれで楽しみです٩(๑❛ᴗ❛๑)۶
