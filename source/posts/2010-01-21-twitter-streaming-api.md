---
title: Twitter の Streaming API について
date: 2010-01-21 11:42 JST
authors: fukunaga
tags: resume, 
---
先日社内でおこなった勉強会で Twitter の [Streaming API](http://apiwiki.twitter.com/Streaming-API-Documentation) について紹介しましたので、以下にそのスライドを貼っておきます。

<!--more-->

<iframe src="http://docs.google.com/present/embed?id=dgbcz6cm_114gdx2mgf7" width="410" frameborder="0" height="342"></iframe>

Streaming API はつい最近正式版となりました。ただ、全公開ステータスを取得できる firehose や Retweet に限定したステータスを取得できる retweet などのメソッドは、まだ特定のアプリケーションアカウントでしか利用できません。

しかし、Streaming API はコネクションをひとつ張れば切断されるまでリアルタイムにデータを取得することができます。従来の REST API では定期的にリクエストを投げてデータを取得する必要がありましたので、その分のコストが削減できます。

ですので、これから Twitter のデータを取得して新しいアプリケーションを構築しようとする場合は、Streaming API の利用を考慮に入れておくとよいかなと思います。

