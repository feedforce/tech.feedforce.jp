---
title: 自由研究：フィード巡回ボットのHTTPリクエスト観察日記
date: 2007-09-20 15:45 JST
authors: ff_koshigoe
tags: resume, 
---
夏の自由研究を9月頭に行ったので、その経過などをここで発表したいと思います。

<!--more-->  

### １日目

フィードを巡回するボットが、どんなHTTPリクエストを行っているのか気になったので、HTTPリクエストのログを記録することにしました。

これから、ログを観察していこうと思います。
- どんなHTTPリクエストをしているのだろう？
- 知らないHTTPリクエストヘッダとかあるかな？
- 対応できていないHTTPリクエストヘッダとかあるかな？

ログを記録には、簡単なPHPスクリプトを使います。
- CGIで動作しているので、$\_SERVER['HTTP\_\*']からHTTPリクエストヘッダを抽出します
- スクリプトは最終的にフィードを返します
- そのほか、必要に応じて修正していきます

巡回してもらうために、いくつかのフィードリーダーに登録しました。
- Google Reader
- はてなRSS
- Livedoor Reader
- Google Blogsearch(ping)
- My Yahoo(ping)
- Feedpath

### ２日目

だいぶ、ログが溜まりました。

早速、知らなかったHTTPリクエストヘッダが登場しました。
- Connection: TE, close
- Te: deflate,gzip;q=0.3
- A-Im: feed
- A-Im: channel

気になることもありました。
- ボットによってIf-Modified-Sinceをつけたりつけなかったりしている

まず、If-Modified-Sinceについてですが、結果から言えばLast-Modifiedの付け忘れでした。ボットによっては、フィードの中から最終更新日時を記録してくれるようで、HTTPレスポンスヘッダに関わらず条件付GETを行ってくれるようです。安全のため、プログラムでフィードを返す場合はLast-Modifiedを忘れないようにしないといけません。
- 観察用スクリプトをLast-Modifiedと304応答に対応しました

続いて、"Connection: TE, close"ですが、これはホップバイホップヘッダであるTEを書いているだけですね。このあたりは曖昧に記憶していました。お恥ずかしい。

さて、それではA-Imにいきましょう。これはなんでしょうか。  
RFC3229(Delta encoding in HTTP)にA-IMに関する記述があります。

> ```
> 10.5.3 A-IM

The A-IM request-header field is similar to Accept, but restricts the instance-manipulations (section 10.1) that are acceptable in the response. As specified in section 10.5.2, a response may be the result of applying multiple instance-manipulations.

 A-IM = "A-IM" ":" #( instance-manipulation
> [";" "q" "=" qvalue] )
> ```
>   
>   
> [Delta encoding in HTTP](http://ietf.org/rfc/rfc3229.txt)  

> ```
> 10.5.3 A-IM

A-IM リクエストヘッダフィールドは Accept に似ているが、レスポンス中に受け入れ可能な instance-manipulation (section 10.1) を制限する。
> section 10.5.2 にて明示されるように、レスポンスは複数の instance-manipulation を適用した結果であるかもしれない。

> A-IM = "A-IM" ":" #( instance-manipulation
> [";" "q" "=" qvalue] )
> ```
>   
>   
> [HTTP における差分エンコーディング](http://www.studyinghttp.net/cgi-bin/rfc.cgi?3229#Sec10.5.3)  

なるほど。インスタンス操作のための仕様ですか。  
それでは、理解もそこそこに、"A-Im: feed"をGoogleから探してみましょう。

> In short, it allows you to only send new entries in your Atom feeds down to the clients. The client program adds a few HTTP headers (a If-Modified-Since to tell you what the last time they got was and an A-IM that indicates you support the 'feed' IM) and things just magically work.  
>   
> [Rooneg::Weblog: mod\_speedyfeed 0.02](http://asdf.blogs.com/asdf/2004/09/mod_speedyfeed__1.html)  

> Atom フィードのダウンロード速度を上昇させる Apache モジュール。仕組みはフィルタモジュールとして動作し、Content Type が application/atom+xml の場合、クライアントから送られてくる If-Modified-Since ヘッダを調べて、新しい記事のフィードのみを配信するという仕組み。  
>   
> [mod\_speedyfeed : NDO::Weblog](http://naoya.dyndns.org/~naoya/mt/archives/001346.html)  

Atom用の仕様で、クライアントが最後に取得したエントリーのタイムスタンプを教えると最新のエントリだけを取得できるようにする仕組みのようですね。

さてさて、"A-Im: channel"はどうでしょうか。  
残念ながら、分かりませんでした。名前からして、RSS1.0/RSS2.0に使えるのではないかと推測しています。

それでは、最後に"Te: deflate,gzip;q=0.3"です。どうもAccept-Encodingのようなにおいがしますが、どうでしょうか。

> ```
> 14.39 TE

The TE request-header field indicates what extension transfer-codings it is willing to accept in the response and whether or not it is willing to accept trailer fields in a chunked transfer-coding. Its value may consist of the keyword "trailers" and/or a comma-separated list of extension transfer-coding names with optional accept parameters (as described in section 3.6).
> ```
>   
>   
> [Hypertext Transfer Protocol -- HTTP/1.1](http://ietf.org/rfc/rfc2616.txt)  

> ```
> 14.39 TE

TE リクエストヘッダフィールドは、レスポンスとしてどんな拡張転送コーディングを受け入れられるか、またチャンク形式転送コーディング内の trailer フィールドを受け入れられるかどうかを示す。
> この値は、"trailers" というキーワードや、 (section 3.6 にて定義される) 拡張転送コーディングの名前と省略可能な受け入れパラメータをコンマで区切ったリストからなるだろう。
> ```
>   
>   
> [ハイパーテキスト転送プロトコル -- HTTP/1.1](http://www.studyinghttp.net/cgi-bin/rfc.cgi?2616#Sec14.39)  

"転送コーディング"が鍵のようです。

> ```
> 3.6 Transfer Codings

Transfer-coding values are used to indicate an encoding transformation that has been, can be, or may need to be applied to an entity-body in order to ensure "safe transport" through the network. This differs from a content coding in that the transfer-coding is a property of the message, not of the original entity.
> ```
>   
>   
> [Hypertext Transfer Protocol -- HTTP/1.1](http://ietf.org/rfc/rfc2616.txt)  

> ```
> 3.6 転送コーディング

転送コーディング値は、ネットワークを通して "安全な転送" を保証するために、エンティティボディに適用されている、する事のできる、する必要のあるエンコーディング変換を示すために使われる。
> 転送コーディングは、元のエンティティではなくメッセージの特性である、という点で内容コーディングとは異なる。
> ```
>   
>   
> [ハイパーテキスト転送プロトコル -- HTTP/1.1](http://www.studyinghttp.net/cgi-bin/rfc.cgi?2616#Sec3.6)  

なんとなくわかった気になりました。とにかく、転送時に適用されるエンコーディングということでしょう。つまり、"Te: deflate,gzip;q=0.3"は、「圧縮転送を受け付けます」という意味でしょう。

疲れたのでこのくらいにしましょう。

### ３日目

さて、本日は観察日記の最終日です。

まずは、転送コーディングについてもう少し見てみようと思います。

何よりも気になることは、「Accept-Encodingを使わずにApacheが圧縮したレスポンスを返してくれるのかどうか」です。Apacheでは、mod\_deflateを利用することで、"Accept-Encoding: gzip"なとどしたリクエストに対して、gzip圧縮したレスポンスを返すことが出来ます。このmod\_deflateは、"Te: gzip"としたリクエストについても同様に処理してくれるのでしょうか？もしくは、mod\_deflateとは別の転送コーディング用のモジュール(フィルタ)などが用意されているのでしょうか。

Googleや人に尋ねてみましたが、残念ながら分かりませんでした。調べられた範囲の情報から推測すると、どうもApacheでは対応していないのではないかと考えられます。

それでは、なぜAccept-Encodingを使わずに"Te: deflate,gzip;q=0.3"を使っているのでしょうか？"Te: deflate,gzip;q=0.3"を使っているボットに対してgzip圧縮したフィードを無理やり返してみましたが、正しく表示されています。このことから、ボットが期待していることは「圧縮したレスポンスを受け取る」ということで間違ってはいないと思います。  
おそらく、PerlでHTTP-GETするモジュールの仕様なんでしょう。

さて、"A-Im: channel"ですが、これについてはまったくあてが無いので、あきらめました。

### まとめ

最後に、自由研究で得られたことをまとめてみたいと思います。
- フィード巡回ボットはHTTP/1.0とHTTP/1.1の両方があります
- HTTP/1.1のボットの一部は内容コーディングでなく転送コーディングで圧縮転送を要求します
- 差分エンコーディングに対応したボットが少数ながら存在します
- 転送コーディングと差分エンコーディングについて勉強できました

未解決のまま、もやもやしている疑問について、ご存知の方はぜひ教えてください。よろしくお願いします。
- 本当にApacheでは"Te: deflate,gzip;q=0.3"に"Transfer-Encoding: gzip"と返せないのでしょうか？
- なぜ、一部のボットではAccept-EncodingでなくTeを使うようにしているのでしょうか？
- "A-Im: channel"は、いったい何者でサーバ側でのどのような挙動を期待しているのでしょうか？

### おまけ

特徴があった(気になる点があった)ボットについて書いておきます。

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

