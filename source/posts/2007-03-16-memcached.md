---
title: memcached
date: 2007-03-16 19:08 JST
authors: akahige
tags: infrastructure, resume, 
---
## 何？

オブジェクトをメモリにキャッシュするデーモン。

動的ページを持つウェブアプリケーションの裏側で動くデータベースへの負荷を軽減させることを目的にデザインされている。
- [公式サイト memcached: a distributed memory object caching system](http://www.danga.com/memcached/)

<!--more-->  

### 特徴
- オブジェクトをメモリ上にキャッシュ
- 複数ホスト間でキャッシュ共有可能（リモートからキャッシュにアクセス可能）
- 各言語用のインタフェースライブラリがそろってます
- 実績豊富

## よくある用途
- セッションストア
- DBへのクエリ結果のキャッシュ
- アプリケーションレベルのオブジェクト共有（静的インスタンス）

### セッションストア
- 複数サーバ間のセッション情報共有
- DBを使う方法と比べて負荷がかからなくてうれしい

#### セッションストアとしての問題点

レプリケーションの仕組みがない。  

ので、アプリケーションの性質によっては深刻な単一障害点になってしまう。

そういう場合はDBをセッションストアにしてがんばるしかない。

ほとんどのアプリでは大した問題ではないと思うけど。  
障害時に強制的にログアウトされるとかそんくらい。

##### 参考
- [TokuLog 改め Perl を極めて結婚するブログ - なぜmemcachedをセッション管理用に使うのか](http://d.hatena.ne.jp/tokuhirom/20061216/1166231736)

### DBへのクエリ結果のキャッシュ
- DBへのアクセスを減らせる
- DBはスケールしにくいので、その部分をサポートするのによく使われる

memcachedの本来の目的。

#### MySQL自体のクエリキャッシュとの違い

MySQLのクエリキャッシュはテーブルの構造やテーブル内のレコードが一件でも変更されると破棄されてしまう。  
memcachedのキャッシュは有効期限が過ぎるか明示的に削除しない限り破棄されない。

頻繁に更新されるテーブル、取得に時間がかかるクエリに関してはmemcachedを使った方がキャッシュ効果は高い。
- [MySQL 4.1 リファレンスマニュアル - クエリキャッシュ](http://dev.mysql.com/doc/refman/4.1/ja/query-cache.html)

### アプリケーションレベルのオブジェクト共有（静的インスタンス）
- どんな言語でもアプリケーション全体でのシングルトンが実現できる
- 排他制御は工夫が必要

#### 排他制御について

サーバ側では特に排他制御する仕組みはないっぽいので、必要ならばクライアント側でがんばる。

排他制御がいるような場所では無理に使わない方がいいかも。
- [徒然なるままにBlog - memcachedを使ったPHPのシングルトン実装](http://www.tsujita.jp/blojsom/blog/default/PHP/2007/01/12/memcached%E3%82%92%E4%BD%BF%E3%81%A3%E3%81%9FPHP%E3%81%AE%E3%82%B7%E3%83%B3%E3%82%B0%E3%83%AB%E3%83%88%E3%83%B3%E5%AE%9F%E8%A3%85.html)

## memcachedのインストール

OSはCentOS。  
以下の場所にCentOSで使えるRPMあります。
- [DAG: libevent RPM packages for Red Hat/Fedora](http://dag.wieers.com/rpm/packages/libevent/)
- [DAG: memcached RPM packages for Red Hat/Fedora](http://dag.wieers.com/rpm/packages/memcached/)

ちなみにDebianはapt-getでいけます。

## 起動

```
$ memcached -d -m 128 -l 127.0.0.1 -p 11211
```

### オプション

manの内容は古いのでmemcached -hの方を優先的に信用。  
ちょっと意味がわからないものもあります。（下の方にまとまってるやつ）

| オプション | 説明 | デフォルト値 |

| -l <ip\_addr> | memcachedがListenするIPアドレス。 セキュリティを考慮するときちんと指定したほうがよい。 | INDRR\_ANY |

| -d | デーモンとして起動 | |

| -s <file> | Unixソケットへのパス | |

| -P <filename> | PIDファイルの指定。デーモンとして動作した場合のみ有効。 | |

| -u <username> | memcachedを起動するユーザーを指定。root権限で実行した場合のみ有効。 | |

| -p <num> | ListenするTCPポート番号。 | 11211 |

| -U <num> | ListenするUDPポート番号。 | 0, Off |

| -m <num> | キャッシュとして利用するメモリの最大容量。単位はMB。 | 64 |

| -c <num> | 最大同時接続数。 | 1024 |

| -M | メモリを使い果たしたとき勝手にキャッシュを削除しないでエラーを返す | |

| -n <bytes> | キャッシュ1件(key+value+flags)に割り当てる最小サイズ 単位はバイト。 | 48 |

| -v | errorとwarningを出力 | |

| -vv | -vに加えてクライアントコマンドとレスポンスを出力 | |

| -i | ライセンス表示 | |

| -h | バージョンとヘルプの表示 | |

| -r | コアファイルのサイズ制限を最大化する。 | |

| -k | 巨大なキャッシュを扱うときにキケンなオプション。 | |

| -f <factor> | チャンクサイズの増加係数 | 1.25 |

| -b | 管理されたインスタンスの起動 | |

## PHPの場合

### 導入

#### ライブラリのインストール

5.2.1で試しました。

```
$ pecl install memcache
```

#### php.iniの編集

以下の一行追加。

```
extension=memcache.so
```

これでMemcacheモジュールが使えるようになる。
- [PHP: Memcache 関数](http://jp.php.net/memcache)

#### httpdの再起動

```
$ /etc/init.d/httpd restart
```

オブジェクトはシリアライズされてから保存されるのでリソース型などのオブジェクトは保存できない

### 使い方

つ [マニュアル](http://jp.php.net/memcache)

とりあえず接続テストだけ。

```
$memcache = new Memcache;
$memcache->connect('localhost', 11211) or die ("接続できませんでした");
```

マニュアルのコピペですみません。

じゃあもう少し。

```

if (($res = $memcache->get('key')) === false) {
    $now = date('Y-m-d H:i:s');
    $memcache->set('key', $now, false, 3600);
    $res = $now;
}

echo $res;
```

最初のアクセス日時がキャッシュされる分かりやすい例。

キャッシュがなければキャッシュする。あればキャッシュを取ってくる。  
$memcache->setの引数のfalseは圧縮するかどうか。3600はキャッシュの有効期限を秒で指定。0にすると期限なし。

### セッション管理

自分で作ってもいいけど、すでに作ってる人がいるので使わせてもらうのもいいでしょう。
- [Weird Silence ≫ MemSession](http://weirdsilence.net/software/memsession/)
- [memcachedをPHPのセッションに使う - PHP::PEAR - dozo PukiWiki](http://dozo.matrix.jp/pear/index.php?PECL%2Fmemcache%2Fsession)

上は微妙。下のやつの方がいい。

## Ruby, Railsの場合

### 導入

以下のいずれかのライブラリを使う。いずれもgemで入る。
- Ruby-MemCache
- memcache-client

memcache-clientの方が速いらしい。

### 使い方

詳細はよくまとめられているところがあるので略。
- [RoR Wiki 翻訳 Wiki - HowtoChangeSessionStore](http://techno.hippy.jp/rorwiki/?HowtoChangeSessionStore)
- [memcached Basics for Rails - Ruby on Rails for Newbies](http://www.nubyonrails.com/articles/2006/08/17/memcached-basics-for-rails)

## サーバ構成

### 構成例

#### memcached用のサーバを立てる

セッションストアとして使う場合などに。  

たくさんのウェブサーバたちから接続される。
- 負荷分散クラスタ内のノートが死んでもセッションが切れない
- stickysessionとか使えないロードバランサでも平気

#### httpdと同じホストに突っ込む

データのキャッシュをする際などに。  
ローカルからのみ参照される。
- memcachedはメモリを食うがCPUはそんなに食わない
- httpdはCPUをたくさん食う

ので一緒のホストで動作させても相性がよくて平気。らしい。

そのほか
- ネットワーク帯域節約
- キャッシュするタイミングの違いでそれぞれのサーバに異なるデータがキャッシュされちゃうかも

  - これが問題になるかどうかはケースバイケース

  - ロードバランサにstickysessionは欲しいかも

  - でなければデータ更新のタイミングで必ずdeleteとかflush。

まあ、キャッシュ使うときはいろいろ気をつけて使おう。

## おまけ

### 導入事例
- [ミクシィのCTOが語る「mixiはいかにして増え続けるトラフィックに対処してきたか」：ITpro](http://itpro.nikkeibp.co.jp/article/NEWS/20060330/233820/)
- [naoyaのはてなダイアリー - はてなブックマークの裏側その後](http://d.hatena.ne.jp/naoya/20061020/1161314770)
- ほかいろいろ

