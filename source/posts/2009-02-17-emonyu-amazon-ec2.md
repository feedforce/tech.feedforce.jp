---
title: 「えもにゅ」がAmazon EC2で動くまで
date: 2009-02-17 19:26 JST
authors: fukunaga
tags: infrastructure, operation, 
---
先月末、「<a href="http://emonyu.jp/">えもにゅ</a>」というサービスをリリースしました。さらに12日には携帯から「えもにゅ」に投稿できる「えもにゅモバイル」もリリースしました。
<!--more-->
<ul>
	<li><a href="http://www.feedforce.jp/entries/000854.html">感情を記録できるサービス 『えもにゅ』 をリリース！</a></li>
	<li><a href="http://www.feedforce.jp/entries/000860.html">『えもにゅ』 にモバイル版登場！</a></li>
</ul>
<h3>えもにゅとは</h3>
「<a href="http://emonyu.jp/">えもにゅ</a>」は自分の今の「気持ち」とその「度合い」を選んで投稿するサービスです。投稿した気持ちは「えもにゅくん」というキャラクターの表情によって表現され、ブログパーツを通してブログ上で公開することができます。

感情とブログパーツに特化している点が、これまでのライフログ系のサービスとは異なる点かと思います。

また、「人」と「時間」と「感情」のデータを結びつけて蓄積し、そのデータをAPI経由で公開することで、新たな相乗効果が生まれることを期待しています。(APIは今後公開予定です)
<h3>えもにゅをEC2で動かす</h3>
さて、その「えもにゅ」ですが、サーバーは <a href="http://aws.amazon.com/ec2/">Amazon EC2</a> を利用しています。「なぜ日本のサービスで EC2 なのか？」と思われるかもしれませんが、
<ul>
	<li>個人的に EC2 を使ってみたかった</li>
	<li>日本で EC2 を利用してサービスを展開している事例が少ない</li>
	<li>円高で料金が安くなっている</li>
	<li>日本での利用が増えればEC2のサーバーが日本にもできるかもという淡い期待</li>
</ul>
といった点が EC2 を利用しようと考えた理由です。
<h3>えもにゅの構成</h3>
えもにゅの構成は以下の図のようになっています。

<img src="http://tech.feedforce.jp/wp-content/uploads/2009/02/emonyu-amazon-ec2.gif" alt="えもにゅの構成" />

EC2上にCentOSのインスタンスを起動、その上にPHP, Apache, MySQLなどをインストールしています。今のところインスタンスは1つです。画像やCSSといったスタティックなファイルは Amazon S3 に配備し、 static.emonyu.jp というサブドメインをCNAMEに割り当てています。

また、EC2とS3のみでは画像等のローディングが遅くて使い物にならなかったため、 Amazon CloudFront にキャッシュさせることで、日本からアクセスされても耐えられるようにしています。
<h3>RightScale社のCentOSイメージを利用</h3>
EC2のインスタンスで起動させているAMI(イメージ)は、<a href="http://www.rightscale.com/">RightScale</a>社が提供しているCentOSのイメージを利用しました。

このイメージを利用する際の注意点は、EC2のSmall Instanceで利用可能な160GBのうちの10GBしかルートにマウントされていない点です。

残りの150GBは /mnt に割り当てられています。MySQL を yum でインストールすると /var/lib/mysql にデータディレクトリが作成されますが、上記の通り /var 以下では 10GB までしか利用できないため、 /mnt の下に mysql用のディレクトリを作成して、シンボリックリンクを貼るといった対処が必要になります。
<pre><code>$ cd /var/lib
$ rm mysql
$ ln -s /mnt/var/lib/mysql mysql
$ lllrwxrwxrwx 1 root   root      18  1月  8 22:30 mysql -&gt; /mnt/var/lib/mysql</code></pre>
my.cnf の内容もそれにあわせて書き換えました。
<pre><code>[mysqld]
datadir=/mnt/var/lib/mysql
socket=/mnt/var/lib/mysql/mysql.sock
[mysql.server]
basedir=/mnt/var/lib</code></pre>
また、タイムゾーンが米国時間となっているため、最初に日本時間に変更しておく必要があります。
<pre><code>lrwxrwxrwx 1 root root 30  1月 16 11:16 /etc/localtime -&gt; /usr/share/zoneinfo/Asia/Tokyo</code></pre>
<h3>CloudFrontでスタティックファイルをホスティングする際の注意点</h3>
CloudFrontのサーバは日本に置かれているためアクセスは速いのですが、キャッシュの有効時間を24時間未満に設定することができないため、キャッシュのコントロールがうまくいかないという問題があります。

ファイルの内容が更新されてもキャッシュは無効にならないため、キャッシュを無効にするにはファイル名を変更する必要があります。リリースのたびにファイル名を変更するのは面倒です。

そこで、スタティックファイルのディレクトリにバージョン番号を付与し、リリースのたびにそのバージョン番号を変更していくという、少々めんどくさい方法で対応することにしました。

イメージとしては、
<pre><code>&lt;img src="/img/title.gif" alt="..." /&gt;</code></pre>
という img タグがあったら、
<pre><code>&lt;img src="http://static.emonyu.jp/24/img/title.gif" alt="..." /&gt;</code></pre>
のようにテンプレートを書き換え、画像ファイル等はその番号のディレクトリに配備する、というものです。バージョン番号はデータベースで管理しています。
<h3>S3にファイルを転送する際の注意点</h3>
EC2からS3へファイルを転送するのに、<a href="http://undesigned.org.za/2007/10/22/amazon-s3-php-class">Amazon S3 PHP Class</a>というライブラリを利用しています。このライブラリは以下のようにして利用できるのですが、
<pre><code>$s3-&gt;putObjectFile(
                   '/path/to/style.css',
                   'bucket-name',
                   's3/file/path/css/style.css',
                   S3::ACL_PUBLIC_READ);</code></pre>
putObjectFile() の6番目の引数に適切に Content-Type を与えてあげる必要があります。たとえば上記のように Content-Type なしで転送してしまうと、ライブラリがデフォルトの Content-Type として text/plain を適用してしまうために、ブラウザでページを表示したときにCSSが適用されなくなります。そのため、
<pre><code>$s3-&gt;putObjectFile(
                   '/path/to/style.css',
                   'bucket-name',
                   's3/file/path/css/style.css',
                   S3::ACL_PUBLIC_READ,
                   array(),
                   'text/css');</code></pre>
のように、最後の引数で Content-Type を与える必要があります。もしくはファイルの拡張子から Content-Type を自動的に判別できるように、ライブラリ自身を修正してもよいと思います。
<h3>まとめ</h3>
以上のように少し手間と工夫が必要ですが、Amazon EC2, S3, CloudFrontを利用して日本向けのサービスを提供することができます。

今後は既存ユーザの利便性向上やAPIの公開、クラウドを生かした新機能の開発などをしていきたいと考えています。

というわけで、ぜひぜひ「<a href="http://emonyu.jp/" target="_blank">えもにゅ</a>」を使ってみてください。

<a href="http://emonyu.jp/" target="_blank">http://emonyu.jp/ </a>