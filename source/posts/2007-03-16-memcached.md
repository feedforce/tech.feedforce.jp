---
title: memcached
date: 2007-03-16 19:08:17
authors: akahige
tags: infrastructure, resume, 
---
  <h2><span class="date"><a name="l0"> </a></span><span class="title">何？</span></h2>
  <div class="body">
    <div class="section">
      <p>オブジェクトをメモリにキャッシュするデーモン。</p>
<p>動的ページを持つウェブアプリケーションの裏側で動くデータベースへの負荷を軽減させることを目的にデザインされている。</p>
<ul>
<li><a href="http://www.danga.com/memcached/" class="external">公式サイト memcached: a distributed memory object caching system</a></li>
<!--more-->
</ul>
    </div>
  </div>
<div class="day">
  <div class="body">
    <div class="section">
      <h3><a name="l2"><span class="sanchor"> </span></a>特徴</h3>

<ul>
<li>オブジェクトをメモリ上にキャッシュ</li>
<li>複数ホスト間でキャッシュ共有可能（リモートからキャッシュにアクセス可能）</li>
<li>各言語用のインタフェースライブラリがそろってます</li>
<li>実績豊富</li>
</ul>
<h2><a name="l3"><span class="sanchor"> </span></a>よくある用途</h2>
<ul>
<li>セッションストア</li>
<li>DBへのクエリ結果のキャッシュ</li>

<li>アプリケーションレベルのオブジェクト共有（静的インスタンス）</li>
</ul>
<h3><a name="l4"> </a>セッションストア</h3>
<ul>
<li>複数サーバ間のセッション情報共有 </li>
<li>DBを使う方法と比べて負荷がかからなくてうれしい</li>
</ul>
<h4><a name="l5"> </a>セッションストアとしての問題点</h4>
<p>レプリケーションの仕組みがない。<br>

ので、アプリケーションの性質によっては深刻な単一障害点になってしまう。</p>
<p>そういう場合はDBをセッションストアにしてがんばるしかない。</p>
<p>ほとんどのアプリでは大した問題ではないと思うけど。<br>
障害時に強制的にログアウトされるとかそんくらい。</p>
<h5><a name="l6"> </a>参考</h5>
<ul>
<li><a href="http://d.hatena.ne.jp/tokuhirom/20061216/1166231736" class="external">TokuLog 改め Perl を極めて結婚するブログ - なぜmemcachedをセッション管理用に使うのか</a></li>
</ul>
<h3><a name="l7"> </a>DBへのクエリ結果のキャッシュ</h3>

<ul>
<li>DBへのアクセスを減らせる </li>
<li>DBはスケールしにくいので、その部分をサポートするのによく使われる</li>
</ul>
<p>memcachedの本来の目的。</p>
<h4><a name="l8"> </a>MySQL自体のクエリキャッシュとの違い</h4>
<p>MySQLのクエリキャッシュはテーブルの構造やテーブル内のレコードが一件でも変更されると破棄されてしまう。<br>
memcachedのキャッシュは有効期限が過ぎるか明示的に削除しない限り破棄されない。</p>
<p>頻繁に更新されるテーブル、取得に時間がかかるクエリに関してはmemcachedを使った方がキャッシュ効果は高い。</p>

<ul>
<li><a href="http://dev.mysql.com/doc/refman/4.1/ja/query-cache.html" class="external">MySQL 4.1 リファレンスマニュアル - クエリキャッシュ</a></li>
</ul>
<h3><a name="l9"> </a>アプリケーションレベルのオブジェクト共有（静的インスタンス）</h3>
<ul>
<li>どんな言語でもアプリケーション全体でのシングルトンが実現できる</li>
<li>排他制御は工夫が必要</li>
</ul>
<h4><a name="l10"> </a>排他制御について</h4>
<p>サーバ側では特に排他制御する仕組みはないっぽいので、必要ならばクライアント側でがんばる。</p>

<p>排他制御がいるような場所では無理に使わない方がいいかも。</p>
<ul>
<li><a href="http://www.tsujita.jp/blojsom/blog/default/PHP/2007/01/12/memcached%E3%82%92%E4%BD%BF%E3%81%A3%E3%81%9FPHP%E3%81%AE%E3%82%B7%E3%83%B3%E3%82%B0%E3%83%AB%E3%83%88%E3%83%B3%E5%AE%9F%E8%A3%85.html" class="external">徒然なるままにBlog - memcachedを使ったPHPのシングルトン実装</a></li>
</ul>
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l11"> </a></span><span class="title">memcachedのインストール</span></h2>
  <div class="body">

    <div class="section">
      <p>OSはCentOS。<br>
以下の場所にCentOSで使えるRPMあります。</p>
<ul>
<li><a href="http://dag.wieers.com/rpm/packages/libevent/" class="external">DAG: libevent RPM packages for Red Hat/Fedora</a></li>
<li><a href="http://dag.wieers.com/rpm/packages/memcached/" class="external">DAG: memcached RPM packages for Red Hat/Fedora</a></li>
</ul>
<p>ちなみにDebianはapt-getでいけます。</p>
    </div>

  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l12"> </a></span><span class="title">起動</span></h2>
  <div class="body">
    <div class="section">
      <pre><code>
$ memcached -d -m 128 -l 127.0.0.1 -p 11211
</code></pre>
<h3><a name="l13"><span class="sanchor"> </span></a>オプション</h3>

<p>manの内容は古いのでmemcached -hの方を優先的に信用。<br>
ちょっと意味がわからないものもあります。（下の方にまとまってるやつ）</p>
<table border="1">
<tr><td>オプション    </td><td>説明 </td><td>デフォルト値</td></tr>
<tr><td>-l &lt;ip_addr&gt;  </td><td>memcachedがListenするIPアドレス。 セキュリティを考慮するときちんと指定したほうがよい。 </td><td> INDRR_ANY </td></tr>
<tr><td>-d            </td><td>デーモンとして起動 </td><td> </td></tr>

<tr><td>-s &lt;file&gt;     </td><td> Unixソケットへのパス</td><td> </td></tr>
<tr><td>-P &lt;filename&gt; </td><td>PIDファイルの指定。デーモンとして動作した場合のみ有効。</td><td> </td></tr>
<tr><td>-u &lt;username&gt; </td><td>memcachedを起動するユーザーを指定。root権限で実行した場合のみ有効。</td><td> </td></tr>

<tr><td>-p &lt;num&gt;      </td><td>ListenするTCPポート番号。</td><td> 11211 </td></tr>
<tr><td>-U &lt;num&gt;      </td><td>ListenするUDPポート番号。</td><td> 0, Off </td></tr>
<tr><td>-m &lt;num&gt;      </td><td>キャッシュとして利用するメモリの最大容量。単位はMB。</td><td> 64 </td></tr>

<tr><td>-c &lt;num&gt;      </td><td> 最大同時接続数。 </td><td> 1024 </td></tr>
<tr><td>-M            </td><td>メモリを使い果たしたとき勝手にキャッシュを削除しないでエラーを返す</td><td> </td></tr>
<tr><td>-n &lt;bytes&gt;    </td><td>キャッシュ1件(key+value+flags)に割り当てる最小サイズ 単位はバイト。</td><td> 48 </td></tr>

<tr><td>-v            </td><td>errorとwarningを出力</td><td> </td></tr>
<tr><td>-vv           </td><td>-vに加えてクライアントコマンドとレスポンスを出力</td><td> </td></tr>
<tr><td>-i            </td><td>ライセンス表示</td><td> </td></tr>
<tr><td>-h            </td><td>バージョンとヘルプの表示</td><td> </td></tr>
<tr><td>-r             </td><td>コアファイルのサイズ制限を最大化する。</td><td> </td></tr>
<tr><td>-k             </td><td>巨大なキャッシュを扱うときにキケンなオプション。</td><td> </td></tr>
<tr><td>-f &lt;factor&gt;    </td><td>チャンクサイズの増加係数</td><td>1.25</td></tr>

<tr><td>-b             </td><td>管理されたインスタンスの起動</td><td> </td></tr>
</table>
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l14"> </a></span><span class="title">PHPの場合</span></h2>
  <div class="body">

    <div class="section">
      <h3><a name="l15"><span class="sanchor"> </span></a>導入</h3>
<h4><a name="l16"> </a>ライブラリのインストール</h4>
<p>5.2.1で試しました。</p>
<pre><code>
$ pecl install memcache
</code></pre>
<h4><a name="l17"> </a>php.iniの編集</h4>
<p>以下の一行追加。</p>

<pre><code>
extension=memcache.so
</code></pre>
<p>これでMemcacheモジュールが使えるようになる。</p>
<ul>
<li><a href="http://jp.php.net/memcache" class="external">PHP: Memcache 関数</a></li>
</ul>
<h4><a name="l18"> </a>httpdの再起動</h4>
<pre><code>
$ /etc/init.d/httpd restart
</code></pre>
<p>オブジェクトはシリアライズされてから保存されるのでリソース型などのオブジェクトは保存できない</p>

<h3><a name="l19"><span class="sanchor"> </span></a>使い方</h3>
<p>つ <a href="http://jp.php.net/memcache" class="external">マニュアル</a></p>
<p>とりあえず接続テストだけ。</p>
<pre><code>
$memcache = new Memcache;
$memcache-&gt;connect('localhost', 11211) or die ("接続できませんでした");
</code></pre>
<p>マニュアルのコピペですみません。</p>
<p>じゃあもう少し。</p>
<pre><code>

if (($res = $memcache-&gt;get('key')) === false) {
    $now = date('Y-m-d H:i:s');
    $memcache-&gt;set('key', $now, false, 3600);
    $res = $now;
}

echo $res;
</code></pre>
<p>最初のアクセス日時がキャッシュされる分かりやすい例。</p>
<p>キャッシュがなければキャッシュする。あればキャッシュを取ってくる。<br>
$memcache-&gt;setの引数のfalseは圧縮するかどうか。3600はキャッシュの有効期限を秒で指定。0にすると期限なし。</p>
<h3><a name="l20"><span class="sanchor"> </span></a>セッション管理</h3>
<p>自分で作ってもいいけど、すでに作ってる人がいるので使わせてもらうのもいいでしょう。</p>
<ul>

<li><a href="http://weirdsilence.net/software/memsession/" class="external">Weird Silence ≫ MemSession</a></li>
<li><a href="http://dozo.matrix.jp/pear/index.php?PECL%2Fmemcache%2Fsession" class="external">memcachedをPHPのセッションに使う - PHP::PEAR - dozo PukiWiki</a></li>
</ul>
<p>上は微妙。下のやつの方がいい。</p>
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l21"> </a></span><span class="title">Ruby, Railsの場合</span></h2>

  <div class="body">
    <div class="section">
      <h3><a name="l22"><span class="sanchor"> </span></a>導入</h3>
<p>以下のいずれかのライブラリを使う。いずれもgemで入る。</p>
<ul>
<li>Ruby-MemCache</li>
<li>memcache-client</li>
</ul>
<p>memcache-clientの方が速いらしい。</p>

<h3><a name="l23"><span class="sanchor"> </span></a>使い方</h3>
<p>詳細はよくまとめられているところがあるので略。</p>
<ul>
<li><a href="http://techno.hippy.jp/rorwiki/?HowtoChangeSessionStore" class="external">RoR Wiki 翻訳 Wiki - HowtoChangeSessionStore</a></li>
<li><a href="http://www.nubyonrails.com/articles/2006/08/17/memcached-basics-for-rails" class="external">memcached Basics for Rails - Ruby on Rails for Newbies</a></li>
</ul>
    </div>
  </div>
</div>
<div class="day">

  <h2><span class="date"><a name="l24"> </a></span><span class="title">サーバ構成</span></h2>
  <div class="body">
    <div class="section">
      <h3><a name="l25"><span class="sanchor"> </span></a>構成例</h3>
<h4><a name="l26"> </a>memcached用のサーバを立てる</h4>
<p>セッションストアとして使う場合などに。<br>

たくさんのウェブサーバたちから接続される。</p>
<ul>
<li>負荷分散クラスタ内のノートが死んでもセッションが切れない</li>
<li>stickysessionとか使えないロードバランサでも平気</li>
</ul>
<h4><a name="l27"> </a>httpdと同じホストに突っ込む</h4>
<p>データのキャッシュをする際などに。<br>
ローカルからのみ参照される。</p>
<ul>
<li>memcachedはメモリを食うがCPUはそんなに食わない</li>

<li>httpdはCPUをたくさん食う</li>
</ul>
<p>ので一緒のホストで動作させても相性がよくて平気。らしい。</p>
<p>そのほか</p>
<ul>
<li>ネットワーク帯域節約</li>
<li>キャッシュするタイミングの違いでそれぞれのサーバに異なるデータがキャッシュされちゃうかも<ul>
<li>これが問題になるかどうかはケースバイケース</li>
<li>ロードバランサにstickysessionは欲しいかも</li>
<li>でなければデータ更新のタイミングで必ずdeleteとかflush。</li>

</ul></li>
</ul>
<p>まあ、キャッシュ使うときはいろいろ気をつけて使おう。</p>
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l28"> </a></span><span class="title">おまけ</span></h2>
  <div class="body">
    <div class="section">
      <h3><a name="l29"><span class="sanchor"> </span></a>導入事例</h3>

<ul>
<li><a href="http://itpro.nikkeibp.co.jp/article/NEWS/20060330/233820/" class="external">ミクシィのCTOが語る「mixiはいかにして増え続けるトラフィックに対処してきたか」：ITpro</a></li>
<li><a href="http://d.hatena.ne.jp/naoya/20061020/1161314770" class="external">naoyaのはてなダイアリー - はてなブックマークの裏側その後</a></li>
<li>ほかいろいろ</li>
</ul>
    </div>
  </div>
</div>
