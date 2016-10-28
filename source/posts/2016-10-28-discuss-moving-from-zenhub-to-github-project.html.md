---
title: GitHub Project機能が強化されたのでZenHubから移行することを検討してみた
date: 2016-10-28 19:00 JST
authors: tsub
tags: dev_style
---

こんにちは!新卒エンジニアのtsubです!
本日Appleから新型のMacbook Proが発表されたということで早速ポチりました。Touch barのハックにワクワクしております。

そして同じく本日GitHubでProject機能が強化されました。

[Introducing Projects for Organizations](https://github.com/blog/2272-introducing-projects-for-organizations)

私が所属しているチームではZenHubを利用しています。GitHubのProjectはZenHubのBoardに近い機能です。
できることなら余計な拡張など入れずにGitHubを純正で使いたいため、今回も移行を検討してみました。

<!--more-->

## 前回の移行検討のおさらい

知っての通り、GitHubのProject機能は以前からリリースされています。
リリース当時にも移行を検討しましたが、その時は見送りという形になりました。

弊社エンジニアの [@yukiyan](/author/yukiyan) が検討してくれた記事はこちらで公開されています。

[ZenHubからGitHub Projectsに移行することを検討してみる - Qiita](http://qiita.com/yukiyan/items/2f7affaaa5df5f00baf1)

### GitHub Projectへの移行を見送った理由
詳しくは上記のリンクに書いてありますが、まとめるとこんな感じです。

- 複数リポジトリをまたいだProjectは作成できない
- Add cardsでissueを追加するのが面倒
- Estimate(タスクのポイント付け)が無い
- 複数のissueをまとめられるEpicが無い
- issueを動かしてもSlackなどへの通知が無い

特に上3つは困り物で、今のチーム内でのZenHubの運用方針的にないとつらいです 😢

### チーム内でのZenHubの運用方針について
弊社では基本的にタスクの管理をホワイトボード + 付箋でやっています。

私の所属するチームも以前はそうでしたが、最近ZenHubを導入してホワイトボードからおさらばしました 👋

ホワイトボードから移行した理由として、チーム内のエンジニアがMacbook Proを使うようになってデスク以外の場所でも自由に作業するようになったことが大きな要因です。

さて、それではチーム内でどのようにZenHubを使っているか、について簡単にご説明します。

まず、ZenHubのBoardをお見せします。

![:alt](/images/2016/10/discuss-moving-from-zenhub-to-github-project1.jpg)

上記の画像にも載っていますが、以下のパイプラインを用意しています。

* New Issue
  * 新しいissueはまずここに配置します
  * 次のスプリント計画を立てるときは優先順位に応じてここのissueをIceboxやProduct Backlogに振り分けていきます
* Icebox
  * 優先順位の低いタスクです
  * スプリント中にタスクが早く完了した場合などに手を付けます
* Epic
  * ZenHubのEpic機能を使って作ったissueです
  * ここはあまり使わないので今あるEpicが完了したら消す予定です
* Product Backlog
  * 今のスプリントではやらないけど、次回移行にやっていく比較的優先度の高いタスクです
  * ここのタスクを元に次のスプリント計画を立てることが多いです
* Spring Backlog
  * 今のスプリントでやる予定のタスクです
* In Progress
  * 各エンジニアが作業中のタスクです
* In Review
  * 作業が完了してレビュー待ちになったタスクです
* Done
  * PRがマージされ、完了したタスクです
* Closed
  * 後述の振り返りが終わったらissueをCloseしてここに配置されます

また、気づい方もいるかと思いますが、Board上にはissueしか表示させていません。
これは、スプリントの終わりに今週やったタスクの振り返りをしているのですが、その際にPRだとマージしたらClosedに移動してしまってそのスプリントにやったタスクを探しづらいためです。

PRをマージしてもissueをDoneに移動させておくことで、そのスプリントでどのタスクをやったかが分かりやすくなります。

そのため、基本的にはまずissueを作ってそこからPRを作る、という流れで作業をしています。

## オーガニゼーション単位でProjectを作成できるようになった
さて、それでは今回の新機能についてです。

今までリポジトリ単位でしか作成できなかったのですが、本日のアップデートによりオーガニゼーション単位で作成できるようになりました 👏

オーガニゼーションのトップにProjectsというタブが追加されています。

![:alt](/images/2016/10/discuss-moving-from-zenhub-to-github-project2.jpg)

Projectsに飛ぶとこんな感じの画面です。

Project名とDescriptionが書けます。
Descriptionはいつものmarkdownが書けるので、チームで使ってるリポジトリとか書くと良さそうですね。

![:alt](/images/2016/10/discuss-moving-from-zenhub-to-github-project3.jpg)

ボードの画面はこんな感じです。
以前からあったリポジトリ毎のProjectとほとんど変わらないです。

![:alt](/images/2016/10/discuss-moving-from-zenhub-to-github-project4.jpg)

## 改めてGitHub Projectの良い点 👍

#### Detailsのサイドバーが地味に便利
ボード画面右上のDetailsをポチッと押すとサイドバーが表示されます。

実はProjectのDescriptionに書いた内容がここに表示されます。

こんな感じでリポジトリのリンクとか書いてあると便利に使えると思います。

![:alt](/images/2016/10/discuss-moving-from-zenhub-to-github-project5.jpg)

#### Noteが便利
issueにする必要ないんだけどメモしておきたい、というときに非常に便利です。
そういうことは付箋に書いてもいいんですが、他のメンバーにも周知できるのでこれは良いです。

![:alt](/images/2016/10/discuss-moving-from-zenhub-to-github-project6.jpg)

### 改めてGitHub Projectの悪い点 👎

#### issue側からProjectに関連付けられない
ここは変わらずです。read onlyです。

![:alt](/images/2016/10/discuss-moving-from-zenhub-to-github-project7.jpg)

#### Projectの画面から新しいissueを作れない
作れません。
一旦リポジトリ毎でissueを作り、それをProjectの画面から紐付けるだけです。

面倒です。

#### Projectに紐付けていないissueは見えない
ZenHubではissueを新しく作ると勝手にボードに追加されたので、それを適切な場所に動かすという運用ができたのですが、Projectは勝手にボードに追加してくれません。

そのため、Projectのボードを見れば、全てのissueが載っていることが保証されないため、追加忘れがあると大変なことになります。

## 結局移行するのか 💭
複数リポジトリをまたげるようになったのはかなり大きな変更です。
ただ、現時点ではまだ以下のような問題が残っています。

- Add cardsでissueを追加するのが面倒
- Estimate(タスクのポイント付け)が無い
- 複数のissueをまとめられるEpicが無い
- issueを動かしてもSlackなどへの通知が無い

この内、やはり上の2つが解決されていない以上つらいため今回もGitHub Projectの採用は見送りになりそうです👋

というわけで今後もZenHubを使います

## おまけ ラベルの管理について
ラベル付いてると見やすいなーと思ったそこのあなた！

ラベルの管理方法はこのようにwikiにまとめて運用しています。
チーム内のエンジニアはこのルールに沿って新しいissueを作るときにラベルを付けます。

![:alt](/images/2016/10/discuss-moving-from-zenhub-to-github-project8.jpg)

ラベルを付けることで視認性が上がり、またZenHubのフィルター機能によって表示/非常時を切り替えることができますので大変便利です。

スプリントが始まってすぐの、やる気に満ちあふれている時は`not: "Priority: Low"`などフィルターを設定することで目の前のタスクに集中できます。

## まとめ
今回もやはりZenHubのほうがまだまだ便利だと感じて移行を見送ることになりました。
チームによってはGitHub Project機能を使っていたり、ホワイトボードでタスクを管理しているようですので、チームメンバーの趣向によって使い分けていけば良いと思います。

それでは、良い週末を! 🍻
