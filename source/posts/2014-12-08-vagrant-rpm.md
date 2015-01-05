---
title: Vagrantで簡単に作れる！！RubyやKyotoTycoonのrpmたち
date: 2014-12-08 14:00 JST
authors: masutaka
tags: ruby, infrastructure, test
---
皆さんお元気ですか。
Debian GNU/Linux好きだけど、最近rpmの作り方を習得した増田です。

![jenkins-rpm](/images/2014/12/jenkins-rpm.png)

<!--more-->

## 昔話

初めてRedHat Linuxに触れたのは7.1の頃(2002年？)。あの頃は配布されているrpmが少なく、make installに逃げていました。

そんな中出会ったDebian GNU/Linux。配布パッケージが膨大で、手動ビルドの手間から逃れることが出来ました。Emacsとか興味あるアプリはビルドしてましたが。

## サーバのCIとrpm作成

時は流れ2014年。先日こんな記事を公開しました。

* [JenkinsでサーバのCIを始めました | feedforce Engineers' blog](http://tech.feedforce.jp/jenkins-server-ci.html)

実はこの時は、CookのたびにRubyやKyotoTycoonをビルドしていたため、CIに30分くらいかかっていました。CIに使うEC2インスタンスはt1.microでしたし。。

これでは使いものにならないということで、重い腰を上げて作ったrpmがこちら。Rubyは https://github.com/hansode/ruby-2.1.x-rpm からのforkです。ありがとうございます。

* https://github.com/feedforce/ruby-rpm
* https://github.com/feedforce/kyototycoon-rpm
* https://github.com/feedforce/kyotocabinet-rpm

それぞれSRPMとRPMもダウンロードできます。ご利用は自己責任で。

* https://github.com/feedforce/ruby-rpm/releases
* https://github.com/feedforce/kyototycoon-rpm/releases
* https://github.com/feedforce/kyotocabinet-rpm/releases

32分が5分程度に短縮されました。振り切れているのが32分です。

![jenkins-graph](/images/2014/12/jenkins-graph.png)

今では簡単な修正はCIに任せているため、手元でCookすることが減り、コードを書く時間が増えました。

## Rubyのバージョンアップに素早く追随

これだけだと芸がないので、[Vagrant](https://www.vagrantup.com/)と[VirtualBox](https://www.virtualbox.org/)を使って簡単にSRPMとRPMを作れるようにしました。

このように機械的に作れます([README.md](https://github.com/feedforce/ruby-rpm/blob/master/README.md)から抜粋)。

```shell-session
$ git clone git@github.com:feedforce/ruby-rpm.git
$ cd ruby-2.1.x-rpm
$ vagrant up
$ vagrant ssh
$ mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
$ (cd ~/rpmbuild/SOURCES && curl -LO http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz)
$ cp /vagrant/ruby21x.spec ~/rpmbuild/SPECS
$ sudo yum update -y
$ sudo yum install -y rpm-build
$ rpmbuild -ba ~/rpmbuild/SPECS/ruby21x.spec
エラー: ビルド依存性の失敗:
        readline-devel は ruby-2.1.5-2.el6.x86_64 に必要とされています
        ncurses-devel は ruby-2.1.5-2.el6.x86_64 に必要とされています
        gdbm-devel は ruby-2.1.5-2.el6.x86_64 に必要とされています
        glibc-devel は ruby-2.1.5-2.el6.x86_64 に必要とされています
        gcc は ruby-2.1.5-2.el6.x86_64 に必要とされています
        openssl-devel は ruby-2.1.5-2.el6.x86_64 に必要とされています
        libyaml-devel は ruby-2.1.5-2.el6.x86_64 に必要とされています
        libffi-devel は ruby-2.1.5-2.el6.x86_64 に必要とされています
        zlib-devel は ruby-2.1.5-2.el6.x86_64 に必要とされています
$ sudo yum install -y readline-devel ncurses-devel gdbm-devel glibc-devel gcc openssl-devel libyaml-devel libffi-devel zlib-devel
$ rpmbuild -ba ~/rpmbuild/SPECS/ruby21x.spec
(snip)
書き込み完了: /home/vagrant/rpmbuild/SRPMS/ruby-2.1.5-2.el6.src.rpm
書き込み完了: /home/vagrant/rpmbuild/RPMS/x86_64/ruby-2.1.5-2.el6.x86_64.rpm
```

実際の手順を貼り付けているのでごちゃっとしてますが、付属の[ruby21x.spec](https://github.com/feedforce/ruby-rpm/blob/master/ruby21x.spec)を~/rpmbuild/SPECSにコピーして、rpmbuildしているだけです。

Rubyバージョンアップによるruby21x.specの変更も[このような些細なもの](https://github.com/feedforce/ruby-rpm/commit/4064fe0655cf9dc1427760ee48ef19be8a3a0366)です。

## まとめ

* rpmを自作したらCI時間が短縮されてハッピーになった。
* 手元でCookすることも減り、コードを書く時間が増えた。
* Vagrantを使うとrpmのビルドの属人性が減る。

Let's build rpm!!
