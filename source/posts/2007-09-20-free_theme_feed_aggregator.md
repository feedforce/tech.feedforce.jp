---
title: 自由研究：フィード巡回ボットのHTTPリクエスト観察日記
date: 2007-09-20 15:45 JST
authors: ff_koshigoe
tags: resume, 
---
<p>
夏の自由研究を9月頭に行ったので、その経過などをここで発表したいと思います。
</p>
<!--more-->
<h3>１日目</h3>
<div>
<p>
フィードを巡回するボットが、どんなHTTPリクエストを行っているのか気になったので、HTTPリクエストのログを記録することにしました。
</p>
<p>
これから、ログを観察していこうと思います。
</p>
<ul>
<li>どんなHTTPリクエストをしているのだろう？</li>
<li>知らないHTTPリクエストヘッダとかあるかな？</li>
<li>対応できていないHTTPリクエストヘッダとかあるかな？</li>
</ul>
<p>
ログを記録には、簡単なPHPスクリプトを使います。
</p>
<ul>
<li>CGIで動作しているので、$_SERVER['HTTP_*']からHTTPリクエストヘッダを抽出します</li>
<li>スクリプトは最終的にフィードを返します</li>
<li>そのほか、必要に応じて修正していきます</li>
</ul>
<p>
巡回してもらうために、いくつかのフィードリーダーに登録しました。
</p>
<ul>
<li>Google Reader</li>
<li>はてなRSS</li>
<li>Livedoor Reader</li>
<li>Google Blogsearch(ping)</li>
<li>My Yahoo(ping)</li>
<li>Feedpath</li>
</ul>
</div>

<h3>２日目</h3>
<div>
<p>
だいぶ、ログが溜まりました。
</p>
<p>
早速、知らなかったHTTPリクエストヘッダが登場しました。
</p>
<ul>
<li>Connection: TE, close</li>
<li>Te: deflate,gzip;q=0.3</li>
<li>A-Im: feed</li>
<li>A-Im: channel</li>
</ul>
<p>
気になることもありました。
</p>
<ul>
<li>ボットによってIf-Modified-Sinceをつけたりつけなかったりしている</li>
</ul>
<p>
まず、If-Modified-Sinceについてですが、結果から言えばLast-Modifiedの付け忘れでした。ボットによっては、フィードの中から最終更新日時を記録してくれるようで、HTTPレスポンスヘッダに関わらず条件付GETを行ってくれるようです。安全のため、プログラムでフィードを返す場合はLast-Modifiedを忘れないようにしないといけません。
</p>
<ul>
<li>観察用スクリプトをLast-Modifiedと304応答に対応しました</li>
</ul>
<p>
続いて、"Connection: TE, close"ですが、これはホップバイホップヘッダであるTEを書いているだけですね。このあたりは曖昧に記憶していました。お恥ずかしい。
</p>
<p>
さて、それではA-Imにいきましょう。これはなんでしょうか。<br />
RFC3229(Delta encoding in HTTP)にA-IMに関する記述があります。
</p>
<blockquote>
```

10.5.3 A-IM

The A-IM request-header field is similar to Accept, but restricts the instance-manipulations (section 10.1) that are acceptable in the response.  As specified in section 10.5.2, a response may be the result of applying multiple instance-manipulations.

   A-IM = "A-IM" ":" #( instance-manipulation
                            [ ";" "q" "=" qvalue ] )

```
<a href="http://ietf.org/rfc/rfc3229.txt" target="_blank">Delta encoding in HTTP</a>
</blockquote>
<blockquote>
```

10.5.3 A-IM

A-IM リクエストヘッダフィールドは Accept に似ているが、レスポンス中に受け入れ可能な instance-manipulation (section 10.1) を制限する。
section 10.5.2 にて明示されるように、レスポンスは複数の instance-manipulation を適用した結果であるかもしれない。

   A-IM = "A-IM" ":" #( instance-manipulation
                            [ ";" "q" "=" qvalue ] )

```
<a href="http://www.studyinghttp.net/cgi-bin/rfc.cgi?3229#Sec10.5.3" target="_blank">HTTP における差分エンコーディング</a>
</blockquote>
<p>
なるほど。インスタンス操作のための仕様ですか。<br />
それでは、理解もそこそこに、"A-Im: feed"をGoogleから探してみましょう。
</p>
<blockquote>
In short, it allows you to only send new entries in your Atom feeds down to the clients. The client program adds a few HTTP headers (a If-Modified-Since to tell you what the last time they got was and an A-IM that indicates you support the 'feed' IM) and things just magically work.
<a href="http://asdf.blogs.com/asdf/2004/09/mod_speedyfeed__1.html" target="_blank">Rooneg::Weblog: mod_speedyfeed 0.02</a>
</blockquote>
<blockquote>
Atom フィードのダウンロード速度を上昇させる Apache モジュール。仕組みはフィルタモジュールとして動作し、Content Type が application/atom+xml の場合、クライアントから送られてくる If-Modified-Since ヘッダを調べて、新しい記事のフィードのみを配信するという仕組み。
<a href="http://naoya.dyndns.org/~naoya/mt/archives/001346.html" target="_blank">mod_speedyfeed : NDO::Weblog</a>
</blockquote>
<p>
Atom用の仕様で、クライアントが最後に取得したエントリーのタイムスタンプを教えると最新のエントリだけを取得できるようにする仕組みのようですね。
</p>
<p>
さてさて、"A-Im: channel"はどうでしょうか。<br />
残念ながら、分かりませんでした。名前からして、RSS1.0/RSS2.0に使えるのではないかと推測しています。
</p>
<p>
それでは、最後に"Te: deflate,gzip;q=0.3"です。どうもAccept-Encodingのようなにおいがしますが、どうでしょうか。
</p>
<blockquote>
```

14.39 TE

The TE request-header field indicates what extension transfer-codings it is willing to accept in the response and whether or not it is willing to accept trailer fields in a chunked transfer-coding. Its value may consist of the keyword "trailers" and/or a comma-separated list of extension transfer-coding names with optional accept parameters (as described in section 3.6).

```
<a href="http://ietf.org/rfc/rfc2616.txt" target="_blank">Hypertext Transfer Protocol -- HTTP/1.1</a>
</blockquote>
<blockquote>
```

14.39 TE

TE リクエストヘッダフィールドは、レスポンスとしてどんな拡張転送コーディングを受け入れられるか、またチャンク形式転送コーディング内の trailer フィールドを受け入れられるかどうかを示す。
この値は、"trailers" というキーワードや、 (section 3.6 にて定義される) 拡張転送コーディングの名前と省略可能な受け入れパラメータをコンマで区切ったリストからなるだろう。

```
<a href="http://www.studyinghttp.net/cgi-bin/rfc.cgi?2616#Sec14.39" target="_blank">ハイパーテキスト転送プロトコル -- HTTP/1.1</a>
</blockquote>
<p>
"転送コーディング"が鍵のようです。
</p>
<blockquote>
```

3.6 Transfer Codings

Transfer-coding values are used to indicate an encoding transformation that has been, can be, or may need to be applied to an entity-body in order to ensure "safe transport" through the network. This differs from a content coding in that the transfer-coding is a property of the message, not of the original entity.

```
<a href="http://ietf.org/rfc/rfc2616.txt" target="_blank">Hypertext Transfer Protocol -- HTTP/1.1</a>
</blockquote>
<blockquote>
```

3.6 転送コーディング

転送コーディング値は、ネットワークを通して "安全な転送" を保証するために、エンティティボディに適用されている、する事のできる、する必要のあるエンコーディング変換を示すために使われる。
転送コーディングは、元のエンティティではなくメッセージの特性である、という点で内容コーディングとは異なる。

```
<a href="http://www.studyinghttp.net/cgi-bin/rfc.cgi?2616#Sec3.6" target="_blank">ハイパーテキスト転送プロトコル -- HTTP/1.1</a>
</blockquote>
<p>
なんとなくわかった気になりました。とにかく、転送時に適用されるエンコーディングということでしょう。つまり、"Te: deflate,gzip;q=0.3"は、「圧縮転送を受け付けます」という意味でしょう。
</p>
<p>
疲れたのでこのくらいにしましょう。
</p>
</div>

<h3>３日目</h3>
<div>
<p>
さて、本日は観察日記の最終日です。
</p>
<p>
まずは、転送コーディングについてもう少し見てみようと思います。
</p>
<p>
何よりも気になることは、「Accept-Encodingを使わずにApacheが圧縮したレスポンスを返してくれるのかどうか」です。Apacheでは、mod_deflateを利用することで、"Accept-Encoding: gzip"なとどしたリクエストに対して、gzip圧縮したレスポンスを返すことが出来ます。このmod_deflateは、"Te: gzip"としたリクエストについても同様に処理してくれるのでしょうか？もしくは、mod_deflateとは別の転送コーディング用のモジュール(フィルタ)などが用意されているのでしょうか。
</p>
<p>
Googleや人に尋ねてみましたが、残念ながら分かりませんでした。調べられた範囲の情報から推測すると、どうもApacheでは対応していないのではないかと考えられます。
</p>
<p>
それでは、なぜAccept-Encodingを使わずに"Te: deflate,gzip;q=0.3"を使っているのでしょうか？"Te: deflate,gzip;q=0.3"を使っているボットに対してgzip圧縮したフィードを無理やり返してみましたが、正しく表示されています。このことから、ボットが期待していることは「圧縮したレスポンスを受け取る」ということで間違ってはいないと思います。<br />
おそらく、PerlでHTTP-GETするモジュールの仕様なんでしょう。
</p>
<p>
さて、"A-Im: channel"ですが、これについてはまったくあてが無いので、あきらめました。
</p>
</div>
<h3>まとめ</h3>
<div>
<p>
最後に、自由研究で得られたことをまとめてみたいと思います。
</p>
<ul>
<li>フィード巡回ボットはHTTP/1.0とHTTP/1.1の両方があります</li>
<li>HTTP/1.1のボットの一部は内容コーディングでなく転送コーディングで圧縮転送を要求します</li>
<li>差分エンコーディングに対応したボットが少数ながら存在します</li>
<li>転送コーディングと差分エンコーディングについて勉強できました</li>
</ul>
<p>
未解決のまま、もやもやしている疑問について、ご存知の方はぜひ教えてください。よろしくお願いします。
</p>
<ul>
<li>本当にApacheでは"Te: deflate,gzip;q=0.3"に"Transfer-Encoding: gzip"と返せないのでしょうか？</li>
<li>なぜ、一部のボットではAccept-EncodingでなくTeを使うようにしているのでしょうか？</li>
<li>"A-Im: channel"は、いったい何者でサーバ側でのどのような挙動を期待しているのでしょうか？</li>
</ul>
</div>
<h3>おまけ</h3>
<div>
<p>
特徴があった(気になる点があった)ボットについて書いておきます。
</p>
<dl>
<dt>Bloglines</dt>
<dd>
<ul>
<li>A-Im: feed</li>
</ul>
</dd>
<dt>はてなRSS</dt>
<dd>
<ul>
<li>Te: deflate,gzip;q=0.3</li>
</ul>
</dd>
<dt>Livedoor Reader</dt>
<dd>
<ul>
<li>Te: deflate,gzip;q=0.3</li>
</ul>
</dd>
<dt>Feedpath</dt>
<dd>
<ul>
<li>A-Im: channel</li>
</ul>
</dd>
</dl>
</div>
