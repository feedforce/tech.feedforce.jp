---
title: Geo Tagging関連情報まとめ
date: 2007-04-03 10:08 JST
authors: fukunaga
tags: resume, 
---
[Google Maps APIがGeoRSSに対応した](http://googlemapsapi.blogspot.com/2007/03/kml-and-georss-support-added-to-google.html)ことで、RSSに位置情報を追加するGeoRSSがにわかに注目を集めています(個人的に)。

一般にウェブや画像やRSSフィードに位置情報のメタデータを追加することを“GeoTagging”と呼ぶそうです。そこで今日はGeoRSSに手をつける前に、GeoTagging関連の情報を整理して紹介します。(まとめネタです。)

<!--more-->

- GeoTagging
  - マイクロフォーマット
    - 使い方
      - 3つのクラスを使う場合
      - 1つのクラスを使う場合
      - 注意
  - Geocaching
  - 画像にGeoTagging
  - Flickr: GeoTagging Flickr
  - GeoURL
    - ウェブサイトをGeoTagging
    - GeoURLへpingを送信
    - GeoURLでRSSフィードにGeoTagging
    - さらにRSSフィードにGeoTagging
  - GeoRSS
    - Simple GeoRSS
    - GML
    - Google Maps APIでのKML/GeoRSS対応
    - 参考資料

## GeoTagging

[GeoTagging - Wikipedia, the free encyclopedia](http://en.wikipedia.org/wiki/GeoTagging)  
ウェブや画像やRSSフィードに位置情報のメタデータを追加する処理のことです。緯度と経度がメインですが、それ以外に高度や地名をタギングすることもあります。

### マイクロフォーマット

[Geo (microformat) - Wikipedia, the free encyclopedia](http://en.wikipedia.org/wiki/Geo_%28microformat%29)  
マイクロフォーマットにも位置情報のためのフォーマットが規定されています。

#### 使い方

##### 3つのクラスを使う場合

```html
<div class="geo">後楽園: <span class="latitude">35.707898</span>;<span class="longitude">139.751864</span></div>
```

##### 1つのクラスを使う場合

セミコロン区切りで緯度;経度の順に記述します。

```html
後楽園は<span class="geo">52.686; -2.193</span>の地点にあります。
後楽園は<abbr class="geo" title="52.686;-2.193">52.686, -2.193</abbr>の地点にあります。
後楽園は<abbr class="geo" title="52.686;-2.193">素敵な場所</abbr>です。
```

##### 注意
- 緯度が出現する場合は経度も出現しなければなりません。- 小数点以下の桁数はゼロ詰めで揃えることが推奨されます。

### Geocaching

[Geocaching - Wikipedia, the free encyclopedia](http://en.wikipedia.org/wiki/Geocaching)  
GPSなどを利用した全地球的な宝探し。位置情報をキャッシュするわけではありません。GeoTagginとはあまり関係ありません。

### 画像にGeoTagging

[Geocoded photo - Wikipedia, the free encyclopedia](http://en.wikipedia.org/wiki/Geocoded_photo)画像の場合はExifヘッダに位置情報を埋め込むらしいです。Exifは最近のデジタルカメラはほとんどが採用しています。位置情報を付加できるデジカメがあるかどうかは定かではありませんが、GPS搭載の携帯なら位置情報を記録する機能があります。また、 [デジカメと連携して位置情報を記録](http://www.rbbtoday.com/news/20060802/32829.html)する商品はあるようです。

### Flickr: GeoTagging Flickr

Flickrは2006年にGeoTag対応しています。(via [Going My Way: GeoTagが入力可能になったFlickr](http://kengo.preston-net.com/archives/002780.shtml))

<dl>
<dt><a href="http://www.flickr.com/help/screencasts/vol1" class="external">Flickr Help Screencast Volume 1: Geotags &amp; You</a></dt>
<dd>FlickrでのGeoTaggingの方法(Screencast)。</dd>
<dt><a href="http://www.flickr.com/groups/geotagging/" class="external">Flickr: GeoTagging Flickr</a></dt>
<dd>Flickr内にあるGeoTaggingグループ。</dd>
<dt><a href="http://www.flickr.com/map/" class="external">Flickr: Explore everyone's geotagged photos on a Map</a></dt>
<dd>FlickrでGeoTaggingされた写真を表示。</dd>
<dt><a href="http://www.flickr.com/people/revdancatt/" class="external">Flickr: Rev Dan Catt</a></dt>
<dd>Flickrの中の人。<a href="http://www.geobloggers.com/archives/" class="external">geobloggers</a>で有名です。</dd>
</dl>

### GeoURL

[GeoURL (2.0)](http://geourl.org/)とは“location-to-URL”のディレクトリサービスです。
- [koshigoewiki:feed:geourl](http://koshigoe.sakura.ne.jp/dokuwiki/doku.php?id=koshigoewiki:feed:geourl)(via 第2回勉強会資料)- [ICBM RSS Module](http://postneo.com/icbm/)

#### ウェブサイトをGeoTagging

```html
<meta name="ICBM" content="XXX.XXXXX, XXX.XXXXX">
<meta name="DC.title" content="THE NAME OF YOUR SITE">
```

[Adding yourself to GeoURL - GeoURL (2.0)](http://geourl.org/add.html)

#### GeoURLへpingを送信

[GeoURL (2.0) ping](http://geourl.org/ping/)

#### GeoURLでRSSフィードにGeoTagging

```xml
<item rdf:about="http://ericrichardson.com/">
 <title>eWorld: eric richardson meets the web</title>
 <link>http://ericrichardson.com/</link>
 <description>About 9.4 km away. Near Los Angeles.</description>
 <geourl:longitude>-118.25201</geourl:longitude>
 <geourl:latitude>34.0456</geourl:latitude>
</item>
(ref [[GeoURL Log: Latitude and longitude data in the RSS feeds - GeoURL (2.0)|http://geourl.org/news/2005/04/26/rssplus.html]])
```

#### さらにRSSフィードにGeoTagging

[koshigoe hiki - [Feed]geourlで地理情報](http://hiki.koshigoe.jp/?%5BFeed%5Dgeourl%A4%C7%C3%CF%CD%FD%BE%F0%CA%F3)

### GeoRSS

[GeoRSS Home](http://www.georss.org/)

#### Simple GeoRSS

```xml
<georss:point>45.256 -71.92</georss:point>
```

#### GML

```xml
<georss:where>
 <gml:Point>
  <gml:pos>45.256 -71.92</gml:pos>
 </gml:Point>
</georss:where>
```

[GML](http://www.opengeospatial.org/groups/?iid=31)はAtom1.0, RSS2.0, RSS1.0での利用を想定していますが、RSS以外の通常のXMLファイルでも使用することができます。

[GeoRSS GML Example](http://www.georss.org/gml.html#examples)

## Google Maps APIでのKML/GeoRSS対応

[KML/GeoRSS Overlays](http://www.google.com/apis/maps/documentation/#XML_Overlays)Google Maps APIでKMLやGeoRSSのファイルを取得して利用するには、GGeoXmlオブジェクトを利用します。GGeoXmlはGOverlayオブジェクトを返します。

```javascript
var map = new GMap2(document.getElementById("map")); 
var geoXml = new GGeoXml("http://www.example.com/rss.xml");
map.addOverlay(geoXml);
```

## 参考資料
- [Google Maps API Official Blog: KML and GeoRSS Support Added to the Google Maps API](http://googlemapsapi.blogspot.com/2007/03/kml-and-georss-support-added-to-google.html)
- [GeoTagging - Wikipedia, the free encyclopedia](http://en.wikipedia.org/wiki/GeoTagging)
- [Geo (microformat) - Wikipedia, the free encyclopedia](http://en.wikipedia.org/wiki/Geo_%28microformat%29)
- [Geocaching - Wikipedia, the free encyclopedia](http://en.wikipedia.org/wiki/Geocaching)
- [Geocoded photo - Wikipedia, the free encyclopedia](http://en.wikipedia.org/wiki/Geocoded_photo)
- [デジカメと持ち歩き、撮影場所を特定できる携帯型のGPSユニット：デジタル家電総合情報サイト：Digital Freak 2006/08/02](http://www.rbbtoday.com/news/20060802/32829.html)
- [Going My Way: GeoTagが入力可能になったFlickr](http://kengo.preston-net.com/archives/002780.shtml)
- [Flickr Help Screencast Volume 1: Geotags & You](http://www.flickr.com/help/screencasts/vol1)
- [Flickr: GeoTagging Flickr](http://www.flickr.com/groups/geotagging/)
- [Flickr: Explore everyone's geotagged photos on a Map](http://www.flickr.com/map/)
- [Flickr: Rev Dan Catt](http://www.flickr.com/people/revdancatt/)
- [geobloggers](http://www.geobloggers.com/archives/)
- [GeoURL (2.0)](http://geourl.org/)
- [koshigoewiki:feed:geourl](http://koshigoe.sakura.ne.jp/dokuwiki/doku.php?id=koshigoewiki:feed:geourl)
- [ICBM RSS Module](http://postneo.com/icbm/)
- [GeoURL Log: Latitude and longitude data in the RSS feeds - GeoURL (2.0)](http://geourl.org/news/2005/04/26/rssplus.html)
- [koshigoe hiki - [Feed]geourlで地理情報](http://hiki.koshigoe.jp/?%5BFeed%5Dgeourl%A4%C7%C3%CF%CD%FD%BE%F0%CA%F3)
- [GeoRSS Home](http://www.georss.org/)
- [GML](http://www.opengeospatial.org/groups/?iid=31)
- [KML/GeoRSS Overlays](http://www.google.com/apis/maps/documentation/#XML_Overlays)

