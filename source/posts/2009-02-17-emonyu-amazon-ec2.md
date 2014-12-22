---
title: 「えもにゅ」がAmazon EC2で動くまで
date: 2009-02-17 19:26 JST
authors: fukunaga
tags: infrastructure, operation, 
---
先月末、「 [えもにゅ](http://emonyu.jp/)」というサービスをリリースしました。さらに12日には携帯から「えもにゅ」に投稿できる「えもにゅモバイル」もリリースしました。  

<!--more-->

- [感情を記録できるサービス 『えもにゅ』 をリリース！](http://www.feedforce.jp/entries/000854.html)
- [『えもにゅ』 にモバイル版登場！](http://www.feedforce.jp/entries/000860.html)

### えもにゅとは
「 [えもにゅ](http://emonyu.jp/)」は自分の今の「気持ち」とその「度合い」を選んで投稿するサービスです。投稿した気持ちは「えもにゅくん」というキャラクターの表情によって表現され、ブログパーツを通してブログ上で公開することができます。

感情とブログパーツに特化している点が、これまでのライフログ系のサービスとは異なる点かと思います。

また、「人」と「時間」と「感情」のデータを結びつけて蓄積し、そのデータをAPI経由で公開することで、新たな相乗効果が生まれることを期待しています。(APIは今後公開予定です)  

### えもにゅをEC2で動かす
さて、その「えもにゅ」ですが、サーバーは [Amazon EC2](http://aws.amazon.com/ec2/) を利用しています。「なぜ日本のサービスで EC2 なのか？」と思われるかもしれませんが、  

- 個人的に EC2 を使ってみたかった
- 日本で EC2 を利用してサービスを展開している事例が少ない
- 円高で料金が安くなっている
- 日本での利用が増えればEC2のサーバーが日本にもできるかもという淡い期待

といった点が EC2 を利用しようと考えた理由です。  

### えもにゅの構成
えもにゅの構成は以下の図のようになっています。

![えもにゅの構成](/images/2009/02/emonyu-amazon-ec2.gif)

EC2上にCentOSのインスタンスを起動、その上にPHP, Apache, MySQLなどをインストールしています。今のところインスタンスは1つです。画像やCSSといったスタティックなファイルは Amazon S3 に配備し、 static.emonyu.jp というサブドメインをCNAMEに割り当てています。

また、EC2とS3のみでは画像等のローディングが遅くて使い物にならなかったため、 Amazon CloudFront にキャッシュさせることで、日本からアクセスされても耐えられるようにしています。  

### RightScale社のCentOSイメージを利用
EC2のインスタンスで起動させているAMI(イメージ)は、 [RightScale](http://www.rightscale.com/)社が提供しているCentOSのイメージを利用しました。

このイメージを利用する際の注意点は、EC2のSmall Instanceで利用可能な160GBのうちの10GBしかルートにマウントされていない点です。

残りの150GBは /mnt に割り当てられています。MySQL を yum でインストールすると /var/lib/mysql にデータディレクトリが作成されますが、上記の通り /var 以下では 10GB までしか利用できないため、 /mnt の下に mysql用のディレクトリを作成して、シンボリックリンクを貼るといった対処が必要になります。  

```
$ cd /var/lib
$ rm mysql
$ ln -s /mnt/var/lib/mysql mysql
$ lllrwxrwxrwx 1 root root 18 1月 8 22:30 mysql -> /mnt/var/lib/mysql
```
my.cnf の内容もそれにあわせて書き換えました。  

```
[mysqld]
datadir=/mnt/var/lib/mysql
socket=/mnt/var/lib/mysql/mysql.sock
[mysql.server]
basedir=/mnt/var/lib
```
また、タイムゾーンが米国時間となっているため、最初に日本時間に変更しておく必要があります。  

```
lrwxrwxrwx 1 root root 30  1月 16 11:16 /etc/localtime -> /usr/share/zoneinfo/Asia/Tokyo
```

### CloudFrontでスタティックファイルをホスティングする際の注意点
CloudFrontのサーバは日本に置かれているためアクセスは速いのですが、キャッシュの有効時間を24時間未満に設定することができないため、キャッシュのコントロールがうまくいかないという問題があります。

ファイルの内容が更新されてもキャッシュは無効にならないため、キャッシュを無効にするにはファイル名を変更する必要があります。リリースのたびにファイル名を変更するのは面倒です。

そこで、スタティックファイルのディレクトリにバージョン番号を付与し、リリースのたびにそのバージョン番号を変更していくという、少々めんどくさい方法で対応することにしました。

イメージとしては、  

```
<img src="/img/title.gif" alt="..." />
```
という img タグがあったら、  

```
<img src="http://static.emonyu.jp/24/img/title.gif" alt="..." />
```
のようにテンプレートを書き換え、画像ファイル等はその番号のディレクトリに配備する、というものです。バージョン番号はデータベースで管理しています。  

### S3にファイルを転送する際の注意点
EC2からS3へファイルを転送するのに、 [Amazon S3 PHP Class](http://undesigned.org.za/2007/10/22/amazon-s3-php-class)というライブラリを利用しています。このライブラリは以下のようにして利用できるのですが、  

```
$s3->putObjectFile(
                   '/path/to/style.css',
                   'bucket-name',
                   's3/file/path/css/style.css',
                   S3::ACL_PUBLIC_READ);
```
putObjectFile() の6番目の引数に適切に Content-Type を与えてあげる必要があります。たとえば上記のように Content-Type なしで転送してしまうと、ライブラリがデフォルトの Content-Type として text/plain を適用してしまうために、ブラウザでページを表示したときにCSSが適用されなくなります。そのため、  

```
$s3->putObjectFile(
                   '/path/to/style.css',
                   'bucket-name',
                   's3/file/path/css/style.css',
                   S3::ACL_PUBLIC_READ,
                   array(),
                   'text/css');
```
のように、最後の引数で Content-Type を与える必要があります。もしくはファイルの拡張子から Content-Type を自動的に判別できるように、ライブラリ自身を修正してもよいと思います。  

### まとめ
以上のように少し手間と工夫が必要ですが、Amazon EC2, S3, CloudFrontを利用して日本向けのサービスを提供することができます。

今後は既存ユーザの利便性向上やAPIの公開、クラウドを生かした新機能の開発などをしていきたいと考えています。

というわけで、ぜひぜひ「 [えもにゅ](http://emonyu.jp/)」を使ってみてください。

[http://emonyu.jp/](http://emonyu.jp/)
