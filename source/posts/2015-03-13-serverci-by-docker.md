---
title: CircleCI + DockerでサーバCI始めました
date: 2015-03-13 10:30 JST
authors: tjinjin
tags: infrastructure, test
---

はじめまして！今年１月からジョインしましたtjinjinです。feedforceでは<s>アニメ</s>インフラを担当しています。ちなみに今季オススメアニメはSHIROBAKOです。

今回サーバCIにDockerを導入しましたので、実際の設定や工夫した点など投稿したいと思います。

<!--more-->

## feedforceのサーバCI

弊社ではこれまでCircleCI + AWSを組み合わせてサーバのCIを行って参りました。

しかし、CircleCIを利用するプロジェクトが増えるにつれ、CircleCIに実行待ちが発生するようになりました。お金の力があればすぐ解決できるのですが（コンテナを増やす）、せっかくだしDockerにしてみない？ということでDockerを業務で採用することにしました。

## Dockerとは
[Docker](https://www.docker.com/) はDocker社が開発しているコンテナ型の仮想化ソフトウェアです。ゲスト型のVMより軽量であり、起動が速いなどの特徴があります。

これまでのCircleCIでの実行ログからAWSのセットアップ時間が遅いということがわかっていたため、Dockerを利用することで環境のセットアップ時間を改善することが今回のポイントになります。

## Dockerの設定
### Dockerfileを準備する

DockerfileとはオリジナルのDocker imageを作成するための設定ファイルのようなものです。この設定に従いDocker imageが作成されます。主にやっていることとして3点あります。

- 公式のDocker imageを元に既存で使っていたイメージと比較を行い、足りないパッケージを事前にインストール（ここは今後改善したい
- Dockerfileの中でChefを事前にインストールさせる
- SSHログイン用するための設定

実際の設定は下記のようになります。（一部修正しています。

```sh
FROM centos:6.6
MAINTAINER FF
RUN yum update -y
RUN yum -y install openssh-server sudo acl attr audit authconfig bzip2 cloog-ppl cronie-anacron \
(中略)
yum clean all && \

## Create user
    useradd docker && \
    passwd -f -u docker && \

## Set up SSH
    mkdir -p /home/docker/.ssh; chown docker /home/docker/.ssh; chmod 700 /home/docker/.ssh && \
echo "<public_key>" > /home/docker/.ssh/authorized_keys && \

    chown docker /home/docker/.ssh/authorized_keys && \
    chmod 600 /home/docker/.ssh/authorized_keys && \

## setup sudoers
    echo "docker ALL=(ALL) ALL" >> /etc/sudoers.d/docker && \

## Set up SSHD config
    sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
    sed -ri 's/^UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \

## Pam認証が有効でもログインするための設定
    sed -i -e 's/^\(session.*pam_loginuid.so\)/#\1/g' /etc/pam.d/sshd && \

## Chef-soloを事前にインストールする
    curl -L https://www.chef.io/chef/install.sh | bash && \

## Init SSHD
    /etc/init.d/sshd start && \
    /etc/init.d/sshd stop

CMD /usr/sbin/sshd -D
```

`&& \`という形でRUNの数をなるべく減らしています。Dockerはinstruction(RUNやCMDなど)毎にイメージを差分コミットしているため、例えばyumパッケージ毎にinstructionを書いてしまうとその分だけimageが分割されます。imageが増えるほど余分な情報が増え、結果的にサイズが大きくなってしまいます。少し強引なやり方にはなりますが、ひとつのコマンドの続きとすることでimageをまとめ、サイズを抑えることが可能です。

### CircleCIのコンテナからDockerコンテナに対してsshできるようにする

弊社では現在Chef-soloとserverspecを使って構成管理しているため、コンテナに対しSSHで接続する必要があります。そこで、Docker起動時にポートを指定しポートフォワーディングさせています。~/.ssh/configでそのポートに対しsshするように設定することで、接続が可能になります。

```sh
Host test
  HostName 127.0.0.1
  User docker
  Port 40122
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile ~/.ssh/<secret_key_path>
  IdentitiesOnly yes
  LogLevel FATAL
```

## CircleCIの設定

秘密鍵はCircleCI上に事前に設定しています。

circle.ymlについては以下のように設定しています。

```sh
machine:
  timezone:
    Asia/Tokyo
  ruby:
    version:
      2.1.4
  services:
    - docker
checkout:
  post:
    - git submodule sync
    - git submodule update --init
dependencies:
  cache_directories:
    - "~/cache"
  pre:
    - cp ./.docker/ssh-config.circleci ~/.ssh/config
    - ./script/docker-build.sh
    - docker run -d --privileged -p 40122:22 docker/centos-sshd; sleep 2
test:
  pre:
    - bundle exec knife solo cook test:
        timeout: 600
  override:
    - bundle exec rake spec:test:
        timeout: 600
```

docker runの際には`--privileged` オプションをつけています。hostnameの変更をするレシピがあり、`--privileged`オプションを付けないと、hostnameの変更がうまくいかなかったためです。

### Docker imageのキャッシュ方法

docker-build.shというスクリプトの中ではキャッシュの有無によって、処理を分岐しています。通常時はキャッシュされたファイルをロードし、Dockerfileに変更がある場合のみビルドをさせることで処理の最適化をしています。

```sh
#!/bin/sh
set -xe

if [ -e ~/cache/centos-sshd.tar ] && [ $(md5sum Dockerfile | cut -d' ' -f1) = $(cat ~/cache/dockerfile.digest) ]
then
  docker load < ~/cache/centos-sshd.tar
else
  mkdir -p ~/cache
  docker build -t docker/centos-sshd .
  md5sum Dockerfile | cut -d' ' -f1 > ~/cache/dockerfile.digest
  docker save docker/centos-sshd > ~/cache/centos-sshd.tar
fi
```

## 実施した結果

結果としては下記のようになりました。

![logo-title](/images/2015/03/result.png)
※ [CircleCI](https://circleci.com/docs/configuration) のカテゴリに基づいてグラフにしています

当初の想定ではdependencies（環境のセットアップをする部分）が短縮できる想定でした。cacheが効いていない赤いグラフでも処理時間が半減していますが、更にcacheを効かせることで約５分の１まで時間を短縮できました。また、想定外の結果でしたが、test工程（chef & serverspec）の時間が圧倒的に短くなりました。AWSはm3.mediumを使っていますが、CircleCIの方が圧倒的に速いみたいですね。全体として１０分以上の短縮ができ、やる意味はあったかと思います。

## 最後に
今回は、DockerHub上においてあるimageを使いましたが、セキュリティ上の問題も考えると管理しておきたいですね。一度共通的なDocker imageを作ってしまえば、ビルドする手間が省けるのでさらなる高速化ができそうです。
