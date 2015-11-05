---
title: SELinuxでlogrotateが失敗した話
date: 2015-11-05 12:32 JST
authors: kunishima
tags: infrastructure, operation
---

こんにちは！先日赤城山に登りましたが、山の上は既に紅葉が終わっていました。lorentzcaです。

今回はSELinuxがメインの記事です。
しかし、SELinuxを無効にする記事ではありません！SELinuxと友達になる記事です。

それでは参ります。

<!--more-->

## はじめに

この記事では、以下のことについて書いてあります。

- SELinuxが原因でlogrotateが失敗している事に気づいた経緯
- SELinuxを設定するにあたって必要な前提知識、用語
- SELinuxの設定方法

こんな人を対象に思い浮かべて書きました。

- SELinuxが原因でlogrotateが失敗して困っている(困ったことがある)人
- SELinuxとは何なのか知りたい人
- SELinuxの設定方法を知りたい人
- もうSELinuxをdisableするのはいやだ！という人

SELinuxは以下の環境で動かしました。

- centos7.1
- libselinux 2.2.2
- selinux-policy 3.13.1

私自身、SELinuxについての理解はまだまだ浅いので、間違った記述があれば教えていただけるとたいへん嬉しいです。

**注** : 本文中に記載されるログやアプリのディレクトリのパス等は、本記事用にvmで再現したものです。

## ある日、logrotateが失敗している事に気づいた

先日、とあるサーバーでアプリのログをlogrotateを使って世代管理することになりました。
アプリのログのパスは/var/www/test/shared/log/以下にあるので、そのようにlogrotateの設定をするPRが出されました。
一通りコードを読み、ステージ環境でlogrotateコマンドを手動実行してアプリのログがローテートされたのを確認し、PRをマージしました。そして、プロダクション環境に反映しました。

しかしその数日後、アプリのログを確認してみるとローテートされていませんでした！わお！

cronのログを見るとlogrotate自体は実行されているようです。logrotateはroot権限で実行されるのでファイルのパーミッションも問題にならないはずです。

SELinuxをEnforcingにしているので、SELinux側で拒否しているのかも、と思い/var/log/audit/audit.logを確認しました。audit.logは、ausearchコマンドを使うことで多少見やすい形に整形され、日付やメッセージのタイプで出力を絞り込むことができます。

今回はSELinuxを疑っているので、オプションでメッセージのタイプをavcに絞り込んでいます。avcとは、アクセスベクターキャッシュの略で、SELinuxのアクセス拒否、許可決定がキャッシュされたものです。

ログには以下のような記録がありました。

```
$ sudo ausearch -m avc
----
time->Fri Oct 30 03:02:09 2015
type=SYSCALL msg=audit(1446174129.272:952): arch=c000003e syscall=257 success=no exit=-13 a0=ffffffffffffff9c a1=7fffe21ad260 a2=90800 a3=0 items=0 ppid=13754 pid=13756 auid=0 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=5 comm="logrotate" exe="/usr/sbin/logrotate" subj=system_u:system_r:logrotate_t:s0-s0:c0.c1023 key=(null)
type=AVC msg=audit(1446174129.272:952): avc:  denied  { read } for  pid=13756 comm="logrotate" name="log" dev="dm-0" ino=13507 scontext=system_u:system_r:logrotate_t:s0-s0:c0.c1023 tcontext=unconfined_u:object_r:var_t:s0 tclass=dir
```

あんまり人間に優しくないログですが、SELinuxがlogrotateを拒否したっぽいことがなんとなーく読み取れます。

## SELinuxの概要

さて、どうやらSELinuxがlogrotateの作業を妨害しているらしい事がわかりました。次はSELinuxにアプリのlogrotateを許可してもらえるように設定していきたいのですが、ログにもなんだかよくわからない単語がたくさんありますし、もう少しSELinuxを理解したほうが良さそうです。

そもそもSELinuxはいったい何に対して、どのようにアクセス制限を行っているのでしょうか。よくわかっていなかったので調べました。

調べたのですが、難しかったので、我々が日々親しんでいるディレクトリやファイルに対するパーミッション(755とか644とかのアレ。DACという方式らしい)と何が違うのか、比べてみました。

||DAC|SELinux|
|:--|:--|:--|
|何に対して？| ディレクトリ、ファイル|ディレクトリ、ファイル|
|どのように制限？|**ユーザー、グループ単位で制限**|**プロセス単位で制限**|

そう、SELinuxはlogrotateなどの**プロセスに対して**アクセス制限を行っていたのです。

具体的にSELinuxが何をしているかというと、プロセスとディレクトリやファイルなどのリソースに対して「タイプ」というラベルを付与しています。
タイプは、プロセスがリソースまたは他のプロセスに対してどのような操作できるかの領域を示す「ドメイン」を定義しています。主にプロセスに対して付与されたタイプをドメインと呼んでいるようです。タイプは「SELinuxコンテキスト」という形式で表現されています。

このタイプを組み合わせることによって、プロセス・リソース間、プロセス・プロセス間の柔軟なアクセス制御を行っています。例えば、タイプAが付与されているプロセスはタイプBが付与されているファイルに対し書き込み権限を持つ、といったふうに制御できます。

そして、それは「ポリシー」で定義することができます。
SELinuxはプロセスが何かするたびにそのポリシーを元に、アクセス拒否、許可を決定しています。

さて、SELinuxはプロセスにアクセス制限をかけていることがわかりました。しかし、**ステージ環境で手動実行した際は動いたのに、なぜcronから実行したlogrotateは制限されたのか**という疑問が残ります。
これはSELinuxの「ドメイン遷移」という機能によるものです。

ドメイン遷移とは、あるプロセスから新しく別のプロセスを立ち上げた際、元のプロセスのドメインと異なるドメインを新しいプロセスに付与できる機能です。
そしてユーザーシェルのドメインは、基本的にドメイン遷移しないのです。いちいち何かコマンドを実行する度にSELinuxで制限されては困るからです。

つまり、ユーザーシェルから実行したlogrotateのドメインはユーザーシェルのドメインのままだったのです。cronから実行されたlogrotateはユーザーシェルから実行されたlogrotateとは異なるドメインで立ち上がります。
cronのドメインから遷移したlogrotateのドメインは、ユーザーシェルのドメインより制限の多いドメインが付与されているので、今回のように実行した環境によって制限されたりされなかったりする現象が起きたのでした。

## タイプを確認する

SELinuxがどのようにアクセス制御をしているか調べました。また、ポリシーとやらで制御方法を定義すればよさそうなことがわかりました。

では、ポリシーを定義するにあたって必要なタイプが、具体的にどのようなものなのか調べてみます。

### コマンドから確認する方法

プロセスに付与されたタイプはpsコマンドのオプションに`Z`を付けると確認できます。ディレクトリやファイルに付与されたタイプはlsコマンドで同じく`Z`オプションを付けると確認できます。

試しにcrondプロセスのタイプと、/etc/crontabファイルのタイプを見てみます。

```
$ ls -Z /etc/crontab
-rw-r--r--. root root system_u:object_r:system_cron_spool_t:s0 /etc/crontab

$ ps Z -C crond
LABEL                             PID TTY      STAT   TIME COMMAND
system_u:system_r:crond_t:s0-s0:c0.c1023 560 ? Ss     0:00 /usr/sbin/crond -n
```

この`system_u:object_r:system_cron_spool_t:s0`と`system_u:system_r:crond_t:s0-s0:c0.c1023`がSELinuxコンテキストです。

`<selinux user>:<role>:<type>:<level>`という構成となっています。タイプ以外にselinuxユーザー、ロール、レベルという項目が有りますが、今回は割愛します！！！

さて、今回ローテートしようとしてうまくいかなかったログファイルは/var/www/test/shared/log/以下にあります。このファイルのSELinuxコンテキストを確認すると、`unconfined_u:object_r:var_t:s0`でした。これをみるとタイプは`var_t`のようです。

これで該当のログファイルのタイプはわかりましたが、logrotateプロセスのタイプはどのように確認すればよいでしょうか。logrotateはcrondなどと違ってデーモンではないので、実行時にしかpsコマンド上に現れません。

そこで、再度audit.logの出番です。

### ログから確認する方法

実は、audit.logを見ればどのドメインからのアクセスがどのタイプに対して行われたか、記録されています！なのでここで改めて先ほどのaudit.logを見てみます。

```
time->Fri Oct 30 03:02:09 2015
type=SYSCALL msg=audit(1446174129.272:952): arch=c000003e syscall=257 success=no exit=-13 a0=ffffffffffffff9c a1=7fffe21ad260 a2=90800 a3=0 items=0 ppid=13754 pid=13756 auid=0 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=5 comm="logrotate" exe="/usr/sbin/logrotate" subj=system_u:system_r:logrotate_t:s0-s0:c0.c1023 key=(null)
type=AVC msg=audit(1446174129.272:952): avc:  denied  { read } for  pid=13756 comm="logrotate" name="log" dev="dm-0" ino=13507 scontext=system_u:system_r:logrotate_t:s0-s0:c0.c1023 tcontext=unconfined_u:object_r:var_t:s0 tclass=dir
```

uid等色々な情報が記録されていますが、今回関係してくるものだけピックアップしてみます。

- scontext : リソースにアクセスしようとしたドメインのSELinuxコンテキスト
- tcontext : アクセス要求されたリソースのSELinuxコンテキスト
- denied  { read } for 部分 : 行われようとした操作とその結果

これを見ると、logrotate\_tドメインがvar\_tタイプのリソースに対しreadしようとしたが拒否されたということがわかります。

logrotate\_tがどうやらlogrotateに付与されているタイプのようです。

## ポリシーを追加する

logrotateに関係するプロセス、リソースのタイプを確認しました。logrotate\_tがvar\_tを扱えるようにポリシーを追加すれば良さそうですね。

ではまずポリシーがどのように管理されているのか、見てみます。

ポリシーの定義は/etc/selinux/targeted/policy/policy.29というファイルにあります。29の部分は環境によって異なるかもしれません。また、このファイルはバイナリファイルです。

ポリシーに定義を新しく追加する際は、モジュールを追加する形で行います。モジュールは、/etc/selinux/targeted/modules/active/modules/以下にある\<name\>.ppというファイルです。こちらもバイナリファイルです。

ポリシーに定義を追加する方法は以下の様な流れで行います。

1. 追加したいポリシーのルールをコードで書く
2. コードをコンパイルする
3. コンパイルして作成したファイルをモジュールとして追加する

### audit2allowでルールを自動生成する

audit.logから1,2の部分を自動で行ってくれるツールがあるのでこれを使ってみます。

#### インストール

policycoreutils-pythonパッケージに含まれています。

```
$ sudo yum install policycoreutils-python
```

#### 実行

```
$ sudo sh -c  'audit2allow -M testapp_logrotate < /var/log/audit/audit.log'
```

testapp\_logrotate.teとtestapp\_logrotate.ppの2つのファイルが作成されます。teファイルがポリシーのルールが書かれたテキストファイル、ppファイルがteファイルをコンパイルしたバイナリファイルです。

これでモジュールを追加する準備ができました。

### teファイルの中身を見てみる

さっそくモジュール追加……の前に、どんなルールが作成されたのか、teファイルの中をみてみます。logrotate\_tドメインにvar\_tタイプのディレクトリに対する読み込み権限を与えていることがわかります。

```
module testapp_logrotate 1.0;

require {
        type var_t;
        type logrotate_t;
        class dir read;
}

#============= logrotate_t ==============
allow logrotate_t var_t:dir read;
```

### モジュールを追加する

いよいよモジュールを追加します。モジュールに関する一連の操作は、semoduleコマンドで行います。

```
$ sudo semodule -i testapp_logrotate.pp
```

追加されたか確認してみます。よさそうですね。

```
$ sudo semodule -l | grep testapp_logrotate
testapp_logrotate       1.0
```

もしモジュールを削除したい場合は以下のようにします。

```
$ sudo semodule -r testapp_logrotate
```

### 手動でルールを生成する

さて、モジュールを取り込み再度logrotateの実行結果を確認すると、またもや失敗していました！今度はファイルに対する、getattrという権限が足りないようです。

```
time->Tue Nov  3 03:03:35 2015
type=SYSCALL msg=audit(1446519815.415:1396): arch=c000003e syscall=262 success=no exit=-13 a0=6 a1=1b43633 a2=7fffd921c610 a3=0 items=0 ppid=8602 pid=8604 auid=0 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=77 comm="logrotate" exe="/usr/sbin/logrotate" subj=system_u:system_r:logrotate_t:s0-s0:c0.c1023 key=(null)
type=AVC msg=audit(1446519815.415:1396): avc:  denied  { getattr } for  pid=8604 comm="logrotate" path="/var/www/test/shared/log/test.log" dev="dm-0" ino=528985 scontext=system_u:system_r:logrotate_t:s0-s0:c0.c1023 tcontext=unconfined_u:object_r:var_t:s0 tclass=file
```

ここでまたaudit2allowを実行しようとしたのですが、前回足りなかったreadのエラーログが流れてしまっており、getattrだけ許可されるルールが生成されてしまいました！ので、手動でルールを定義することにします。

#### teファイルを修正する

audit2allowで作成されたルールを元に、以下のように修正しました。

```
module testapp_logrotate 1.1;

require {
        type var_t;
        type logrotate_t;
        class dir read;
        class file getattr;
}

#============= logrotate_t ==============
allow logrotate_t var_t:dir read;
allow logrotate_t var_t:file getattr;
```

モジュールのバージョンの数字も上げています。これにより、修正後のモジュールがちゃんと追加されているか、確認しやすくなります。

#### teファイルのコンパイルに必要なパッケージをインストール

コンパイルに必要なMakefileが含まれています。

```
$ sudo yum install selinux-policy-devel
```

#### teファイルをコンパイルして追加する

teファイルがあるディレクトリで以下を実行します。

```
$ sudo make -f /usr/share/selinux/devel/Makefile
```

すると、ppファイルが作成されるので、あとは同じように追加していきます。

```
$ sudo semodule -i testapp_logrotate.pp
```

モジュールのバージョンが上がっていればOK！

```
$ sudo semodule -l | grep testapp_logrotate
testapp_logrotate       1.1
```

この後、動作確認のたび新たに足りない権限が発生したのでそのたびに調整が必要でした。
はじめから[ObjectClassesPerms](http://selinuxproject.org/page/ObjectClassesPerms)を見て必要そうな権限を追加しておくのが良いと思います。

結果的には必要な権限を全て満たしたルールを作成して、なんとか無事アプリのログをローテートすることができました！

## まとめ

いかがでしょうか。思ったより長い記事になりましたが、SELinuxのログの見方からSELinuxの概要、具体的な設定の方法までを紹介しました。

SELinuxは難しそうでなかなか手を出しづらい印象がありましたが、今回の調査を通してSELinuxと触れ合ったところ、やはり難しいなと感じました！
しかし、いったん自分なりにSELinuxがどういうものかまとめたことで、SELinuxに対する心理的抵抗は以前に比べ格段に少なくなりました。

この記事をきっかけにSELinuxを使ってみよう、という方が少しでも増えれば嬉しいです！

## 参考リンク

- [Security-Enhanced Linux](https://access.redhat.com/documentation/ja-JP/Red_Hat_Enterprise_Linux/6/html/Security-Enhanced_Linux/index.html)
	- 日本語だしSELinux全体についてまとめてあり参考になりました
- [SELinux Project Wiki](http://selinuxproject.org/)
	- 公式のwiki