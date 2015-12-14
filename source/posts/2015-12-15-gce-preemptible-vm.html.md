---
title: GCE の preemptible VM で、インフラの CI を回し始めました
date: 2015-12-15 10:00 JST
authors: inoue
tags: infrastructure
---

こんにちは！ [a-know](https://twitter.com/a_know) こと、いのうえです。
ここではあまり技術的な記事を書くことが少ない私ですが、今回は少し、踏み込んだ内容の記事をお届けしたいと思います。


...あ、この記事は [フィードフォースエンジニア Advent Calendar 2015](http://www.adventar.org/calendars/906) の 15日目の記事であり、また、[Google Cloud Platform Advent Calendar 2015](http://qiita.com/advent-calendar/2015/gcp)の 15日目の記事でもあります。


<!--more-->


## はじめに

タイトルにある "GCE" とは、いわずもがな、 "**Google Compute Engine**" のことですが、その "**preemptible VM**" とは、下記のような特徴を持ったインスタンスのことです。


* Google の膨大なデータセンターの余剰リソースを活用したインスタンス
    * 低コスト（**最大70%オフ**）
    * 低寿命（最大で24時間までしか持続しない）
* 上記のような特徴以外は、基本的に通常のインスタンスと全く遜色はない
    * **分単位での課金**（最初の10分間は固定）、AWS EC2 に比べると**早い起動速度**、など


このオプションがリリースされたとき、私の頭に真っ先に浮かんだことが、**「これは、Chef & serverspec を活用してのインフラ CI に最適かもしれない」**ということ。


弊社におけるインフラ CI は、少し前から実施はしていたのですが、多少の紆余曲折がありました。


* AWS EC2 を用いてのインフラの CI を実施
    * インスタンスの起動に時間が掛かるなど、速度面での課題があった
* docker を用いてのインフラの CI を実施
    * 本質的な意味でインフラの CI をしていることにはなっていないのでは？という疑問が


こうした経緯もあって、「インフラ CI の "三度目の正直" に、GCE preemptible VM がなれるかもしれない」と考えたわけです。このことを、弊社インフラエンジニアの [tjinjin](http://tech.feedforce.jp/author/tjinjin/) にも話してみたところ、彼はすぐに、プライベートで検証してみてくれました。


[GCEでサーバCIをやってみる - とある元SEの学習日記](http://cross-black777.hatenablog.com/entry/2015/10/31/192310)


そんな中、社内でもちょうど新規プロダクトの立ち上げがあり、そのインフラ周りのリポジトリも新たに作成する必要があったため、「よし、tjinjin の検証結果もあるし、このリポジトリの CI に GCE preemptible VM を使ってみるか！」と一念発起しました。CTO にも快諾してもらって作業を実施し、先日、無事 CI が安定して回るようになりました。

その設定作業に関しては、基本的には先に挙げた tjinjin の検証記事の通りに行えば実施できるのですが、初心者には微妙にわかりにくいところがあったり、また思わぬ落とし穴があったりもしたので、tjinjin への尊敬と感謝の念を込めつつ、"リバイバル執筆" をしてみたいと思います。


...あ、CI の SaaS として、[CircleCI](https://circleci.com/) の利用を前提としています。


## GCE preemptible VM でインフラの CI を行うための設定作業
### 1. vagrant plugin である "vagrant-google" をインストールする

vagrant を活用します。理由はいくつかあって、vagrant を使っていれば、立てたインスタンスの特定やアクセスがラクだったり、 `$ vagrant ssh-config` で config 情報を書き出せたり、とか。これは GCE だから、というわけではなく、AWS でのインフラ CI をやっていたときもこの方法で実施していました。今回もそれに倣うことにします。



### 2. リポジトリを追加する

CI 対象の GitHub リポジトリを、CircleCI の **Add Projects** から追加して下さい。


![Add Project](/images/2015/12/gce-preemptible-vm01.png)


### 3. GCP のプロジェクトを作成する

既存のプロジェクト内で実施しても問題はありませんが、プロジェクトを分けておくと請求書も別で出力される...、、つまり、純粋に CI でどれだけコストが掛かったか、が把握しやすくなるので、オススメかなと思います。
課金設定（支払いアカウントの作成と設定）も、忘れずに。


### 4. API を有効にする

新しくプロジェクトを作成した場合、 Compute Engine API は無効な状態になっています。ので、こちらを有効にして下さい。
API を有効にするのは、Google Developers Console の API Manager から行うことができます。



![API Manager](/images/2015/12/gce-preemptible-vm02.png)



### 5. 認証情報を追加する

先ほどの API Manager の左メニューに、「認証情報」というメニューもあると思います。こちらから、認証情報（サービスアカウント）を追加します。最後に、key ファイルとなる json ファイルを取得しておきます。


### 6. CI 用の鍵を作成し、今回のプロジェクトに登録する
`ssh-keygen` で。passphrase は無し、というのが普通なのかと思います。
説明のため、鍵ファイルの名前はここでは **id_gce-circleci** とします。また、公開鍵の方のファイル内コメントに `<ユーザー名>@<ホスト名>` みたいなところがあると思いますが、この "<ユーザー名>" のところも `circleci` としておきます。


そうして出来た鍵を、GCP プロジェクトに登録します。Compute Engine のコンソールを開き、左サイドメニューの "**メタデータ**" を開いたページ内の "**SSHキー**" タブで登録します。
公開鍵をペーストするわけですが、この鍵に対応するユーザー名については、さきほどの公開鍵内コメントのユーザー名が自動で採用されます。つまり、今回の場合は `circleci` となります。



![SSH キー](/images/2015/12/gce-preemptible-vm03.png)


↑わかりにくいですが、「編集」ボタンから鍵の登録を行うことができます。


この設定をしておくことで、起動した GCE インスタンスに対して下記のようなことが自動で行われるようになります。


* 対応するユーザーの作成
* 登録しておいた公開鍵の authorized_keys への追加
* /etc/sudoers に `<ユーザー名> ALL=NOPASSWD: ALL` の行の追加


ここで頭の片隅に置いておきたいことは、**メタデータの登録をして立てたインスタンスの authorized_keys や /etc/sudoers は、プラットフォーム側で適宜管理されている**、ということです。
例えば、authorized_keys の公開鍵の行をコメントアウトしたり、/etc/sudoers から `<ユーザー名> ALL=NOPASSWD: ALL` の行を削除したりしても、**ある程度の時間が経つとそれらが元に戻る**ようになっています。
なので、authorized\_keys や /etc/sudoers を書き換えるような Chef recipe を書いている場合・書き換え後のファイルの内容を比較するような serverspec を書いているような場合は、この点に注意する必要があります。


### 7. Vagrantfile を作成する
下記のようなかんじです。

```ruby
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "bento/centos-7.1"
  config.ssh.insert_key = false

  config.vm.define :gcp do |gcp|
    gcp.vm.box = "gce"
    gcp.vm.box_url = "https://github.com/mitchellh/vagrant-google/raw/master/google.box"
    gcp.vm.synced_folder ".", "/vagrant", disabled: true

    gcp.vm.provider :google do |google, override|
      google.google_project_id = ENV['GCP_PROJECT_ID']
      google.google_client_email = ENV['GCP_EMAIL']
      google.google_json_key_location = ENV['GCP_KEY_LOCATION']

      google.name = "ci-instance-#{Time.new.to_i}"
      google.zone = "asia-east1-a"
      google.machine_type = "n1-standard-1"

      google.image = "centos-7-v20151104"
      google.disk_size = "10"

      google.preemptible = true
      google.on_host_maintenance = "TERMINATE"

      google.auto_restart = false

      override.ssh.username = 'circleci'
      override.ssh.private_key_path = '~/.ssh/id_gce-circleci'
      override.ssh.pty = true
    end
  end
end
```

いくつかポイントになりそうなところだけに絞って、解説します。


#### Project ID, Client Email, JSON Key Location
これらの値は環境変数で与えています。JSON Key Location は、先ほどの **5. 認証情報を追加する** のところで取得した JSON ファイルのロケーションになります。ひとまずはローカルの適当な場所に置いて、その場所を指定しておいてください。

#### name
いわゆるインスタンス名ですが、現在時刻の UNIX 時間を名前に付け加えています。
これは、GCE が同名インスタンスを複数同時に立ち上げられないためで、CI が複数同時に走ったときのことを考慮しています。（なので、別に時間ではなくてもいいと思います）

#### image
ここでは CentOS 7 のイメージを指定しています。その他の OS のイメージを探す際には、gcloud コマンドで `$ gcloud compute images list --project centos-cloud --no-standard-images` このようにすると、探すことができます。


#### preemptible
これを true にすることで、preemptible なインスタンスが立ち上がります。これを true にしないと、今回の記事の存在意義が揺らぎます。笑


#### ssh.username, ssh.private_key_path
先ほどの 6. の手順でプロジェクトに登録した鍵に関する情報を指定します。「このインスタンスに ssh するのに、どこの鍵を用いたら良いのか」、という観点での指定が必要になります。
例に示してあるように、 `~/.ssh/id_gce-circleci` としておくと、ローカルから ssh 接続するときでも、CI コンテナから ssh 接続するときでも、不都合は少ないのかなと思います。「username」も、6. で指定したとおり、 `circleci` になりますね。



### 8. ローカルから GCE インスタンスの起動を確認する

ここまでできたら、作成した Vagrantfile での GCE インスタンスの起動確認の意味で、 `$ vagrant up --provider=google gcp` してみましょう。Google Developer Console を見るなどして確認することになると思います。
正常にインスタンスが起動していれば、成功です（場合によっては、Console を確認しにいく間もなく、インスタンスが寿命を迎える...ということもあるかも、しれません。しかしそれが、preemptible オプションです。:) ）
確認できたら、 `$ vagrant destroy gcp` してインスタンスを削除しておくのを忘れずに。preemptible とはいえ、最長で 24時間持続する可能性がありますので。。


### 9. CircleCI 側に環境変数を設定する
いよいよ、CircleCI 側への設定に入ります。

まずは環境変数の設定です。先ほどの Vagrantfile で `ENV['xxx']` としているような値をどんどん登録していきましょう。


さきほどの確認時には適当に設定していた JSON Key Location は、いったん `.ssh/ci.json` とでもしておきましょう。もちろん、普通にしていたらそんなところにファイルはできません、が、その疑問については後ほど解消することにします。
それと、Vagrantfile では指定していなかった環境変数をひとつ、余計に指定しておきます。値は、**例の JSON ファイルの中身を文字列として登録**することになります。環境変数名は `$GCP_KEY` とでもしておきましょう。


### 10. CircleCI 側に鍵を登録する
**SSH permisions** メニューから行います。


![SSH permisions](/images/2015/12/gce-preemptible-vm04.png)


ここで登録すると、 Hostname に指定した名前を元に、CI を行っているコンテナ内において、 `~/.ssh/id_<hostname>` のロケーションでその鍵にアクセスできるようになります。なので、今回の例では Hostname は `gce-circleci` と指定することになります。



![SSH permisions](/images/2015/12/gce-preemptible-vm05.png)




### 11. circle.yml を書く
例えば下記のようになります。


```yml
machine:
  timezone:
    Asia/Tokyo

dependencies:
  cache_directories:
    - ~/.vagrant.d
    - ~/tmp
    - ~/cache
  pre:
    - |
      VERSION=1.7.4
      mkdir ~/cache
      cd ~/cache
      if [ ! -f vagrant_${VERSION}_x86_64.deb ]; then
        wget https://dl.bintray.com/mitchellh/vagrant/vagrant_${VERSION}_x86_64.deb
      fi
      sudo dpkg -i vagrant_${VERSION}_x86_64.deb
      if ! vagrant plugin list | fgrep -q vagrant-google; then
        vagrant plugin install vagrant-google
      fi
      cd ~/$CIRCLE_PROJECT_REPONAME
      echo $GCP_KEY > $GCP_KEY_LOCATION
test:
  pre:
    - vagrant up gcp --provider=google
    - vagrant ssh-config --host ci-vm gcp >> ~/.ssh/config
    - bundle exec knife solo bootstrap ci-vm
    - vagrant ssh gcp -c "sudo gpasswd -a circleci wheel"
  override:
    - bundle exec rake spec:ci
  post:
    - vagrant destroy gcp -f
```

ここでもいくつかポイントを絞って触れてみたいと思います。


#### `echo $GCP_KEY > $GCP_KEY_LOCATION`
ここまでやってきた作業の通り、 `$GCP_KEY` には JSON キーファイルの中身が、 `$GCP_KEY_LOCATION` には JSON キーファイルの（あって欲しい）パスが、それぞれ環境変数の値として設定されています。
つまり、**必要となる JSON ファイルはここで作成していることになります**。...さきほどの疑問は解消できましたでしょうか？　これにより、credential 情報をリポジトリに含めずに済んでいます。


#### `vagrant ssh-config --host ci-vm gcp >> ~/.ssh/config`
CI のプロセスの中で起動した GCE インスタンスの ssh-config の情報を `ci-vm` というホスト名で書き出しています。これにより、以降のステップでは `ci-vm` の名前でアクセスできるようになっています。（そのため、chef レシピリポジトリ内 nodes ディレクトリで管理する対象 node に `ci-vm` に対応する node を追加しておくことも、予め必要になります。）


#### `bundle exec rake spec:ci`
CI が立てた GCE インスタンスに対して、serverspec を実行するステップです。対応する rake task はあらかじめ定義しておいて下さい。


### 12. Pull Request を出してみる
Vagrantfile や circle.yml など、ここまでの作業であれこれ変更を加えているかと思います。その作業をまるっと、自分のリポジトリに対して Pull Request してみましょう。きっと、CI が動き始め、諸々の設定に間違いがなければ、めでたく pass するかと思います。


![CI passed](/images/2015/12/gce-preemptible-vm06.png)


## まとめ
手順としては以上となります。少々煩雑になってしまいましたが、いかがでしたでしょうか。
実際にやってみると、それほど大変ではないと思います。現在既に chef recipe での構成管理や serverspec でのインフラのテストなどを行っているのであれば、なおさらかと思います。

みなさんの職場での GCP 利用例の最初の一例として、**GCE preemptible VM の CI 利用**、いかがでしょうか！٩( 'ω' )و

