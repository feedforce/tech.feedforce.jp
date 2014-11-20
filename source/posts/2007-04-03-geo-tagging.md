---
title: Geo Tagging関連情報まとめ
date: 2007-04-03 10:08 JST
authors: fukunaga
tags: resume, 
---
<p><a href="http://googlemapsapi.blogspot.com/2007/03/kml-and-georss-support-added-to-google.html" class="external">Google Maps APIがGeoRSSに対応した</a>ことで、RSSに位置情報を追加するGeoRSSがにわかに注目を集めています(個人的に)。</p>

<p>一般にウェブや画像やRSSフィードに位置情報のメタデータを追加することを“GeoTagging”と呼ぶそうです。そこで今日はGeoRSSに手をつける前に、GeoTagging関連の情報を整理して紹介します。(まとめネタです。)</p>
<!--more-->
<ul>
<li><a href="#l1">GeoTagging</a></li>
<li>
	<ul>
 		<li><a href="#l2">マイクロフォーマット</a></li>
 		<li>
            <ul>
            <li><a href="#l3">使い方</a>
                <ul>
                    <li><a href="#l4">3つのクラスを使う場合</a></li>
                    <li><a href="#l5">1つのクラスを使う場合</a></li>
                    <li><a href="#l6">注意</a></li>
                </ul>
            </li>
            </ul>
         </li>
         <li><a href="#l7">Geocaching</a></li>
         <li><a href="#l8">画像にGeoTagging</a></li>
         <li><a href="#l9">Flickr: GeoTagging Flickr</a></li>
         <li><a href="#l10">GeoURL</a></li>
         <li>
         	<ul>
               <li><a href="#l11">ウェブサイトをGeoTagging</a></li>
               <li><a href="#l12">GeoURLへpingを送信</a></li>
               <li><a href="#l13">GeoURLでRSSフィードにGeoTagging</a></li>
               <li><a href="#l14">さらにRSSフィードにGeoTagging</a></li>
            </ul>
          </li>
        <li><a href="#l15">GeoRSS</a></li>
        <li>
            <ul>
                <li><a href="#l16">Simple GeoRSS</a></li>
                <li><a href="#l17">GML</a></li>
            </ul>
        </li>
        </ul>
        </li>
        <li><a href="#l18">Google Maps APIでのKML/GeoRSS対応</a></li>
        <li><a href="#l19">参考資料</a></li>
</ul>

<h2><span class="date"><a name="l1"> </a></span><span class="title">GeoTagging</span></h2>
<p><a href="http://en.wikipedia.org/wiki/GeoTagging" class="external">GeoTagging - Wikipedia, the free encyclopedia</a><br />
ウェブや画像やRSSフィードに位置情報のメタデータを追加する処理のことです。緯度と経度がメインですが、それ以外に高度や地名をタギングすることもあります。</p>

<h3><a name="l2"><span class="sanchor"> </span></a>マイクロフォーマット</h3>
<p><a href="http://en.wikipedia.org/wiki/Geo_%28microformat%29" class="external">Geo (microformat) - Wikipedia, the free encyclopedia</a><br />
マイクロフォーマットにも位置情報のためのフォーマットが規定されています。</p>

<h4><a name="l3"> </a>使い方</h4>
<h5><a name="l4"> </a>3つのクラスを使う場合</h5>
<pre><code>
&lt;div class="geo"&gt;後楽園: &lt;span class="latitude"&gt;35.707898&lt;/span&gt;;&lt;span class="longitude"&gt;139.751864&lt;/span&gt;&lt;/div&gt;
</code></pre>

<h5><a name="l5"> </a>1つのクラスを使う場合</h5>
<p>セミコロン区切りで緯度;経度の順に記述します。</p>
<pre><code>
後楽園は&lt;span class="geo"&gt;52.686; -2.193&lt;/span&gt;の地点にあります。
後楽園は&lt;abbr class="geo" title="52.686;-2.193"&gt;52.686, -2.193&lt;/abbr&gt;の地点にあります。
後楽園は&lt;abbr class="geo" title="52.686;-2.193"&gt;素敵な場所&lt;/abbr&gt;です。
</code></pre>

<h5><a name="l6"> </a>注意</h5>
<ul>
 <li>緯度が出現する場合は経度も出現しなければなりません。</li>
 <li>小数点以下の桁数はゼロ詰めで揃えることが推奨されます。</li>
</ul>

<h3><a name="l7"><span class="sanchor"> </span></a>Geocaching</h3>
<p><a href="http://en.wikipedia.org/wiki/Geocaching" class="external">Geocaching - Wikipedia, the free encyclopedia</a><br />
GPSなどを利用した全地球的な宝探し。位置情報をキャッシュするわけではありません。GeoTagginとはあまり関係ありません。</p>

<h3><a name="l8"><span class="sanchor"> </span></a>画像にGeoTagging</h3>
<p><a href="http://en.wikipedia.org/wiki/Geocoded_photo" class="external">Geocoded photo - Wikipedia, the free encyclopedia</a>
画像の場合はExifヘッダに位置情報を埋め込むらしいです。Exifは最近のデジタルカメラはほとんどが採用しています。位置情報を付加できるデジカメがあるかどうかは定かではありませんが、GPS搭載の携帯なら位置情報を記録する機能があります。また、<a href="http://www.rbbtoday.com/news/20060802/32829.html" class="external">デジカメと連携して位置情報を記録</a>する商品はあるようです。</p>

<h3><a name="l9"><span class="sanchor"> </span></a>Flickr: GeoTagging Flickr</h3>
<p>Flickrは2006年にGeoTag対応しています。(via <a href="http://kengo.preston-net.com/archives/002780.shtml" class="external">Going My Way: GeoTagが入力可能になったFlickr</a>)</p>

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

<h3><a name="l10"><span class="sanchor"> </span></a>GeoURL</h3>
<p><a href="http://geourl.org/" class="external">GeoURL (2.0)</a>とは“location-to-URL”のディレクトリサービスです。</p>
<ul>
 <li><a href="http://koshigoe.sakura.ne.jp/dokuwiki/doku.php?id=koshigoewiki:feed:geourl" class="external">koshigoewiki:feed:geourl</a>(via 第2回勉強会資料)</li>
 <li><a href="http://postneo.com/icbm/" class="external">ICBM RSS Module</a></li>
</ul>

<h4><a name="l11"> </a>ウェブサイトをGeoTagging</h4>
<pre><code>
&lt;meta name="ICBM" content="XXX.XXXXX, XXX.XXXXX"&gt;
&lt;meta name="DC.title" content="THE NAME OF YOUR SITE"&gt;
</code></pre>

<p><a href="http://geourl.org/add.html" class="external">Adding yourself to GeoURL - GeoURL (2.0)</a></p>
<h4><a name="l12"> </a>GeoURLへpingを送信</h4>
<p><a href="http://geourl.org/ping/" class="external">GeoURL (2.0) ping</a></p>

<h4><a name="l13"> </a>GeoURLでRSSフィードにGeoTagging</h4>
<pre><code>
&lt;item rdf:about="http://ericrichardson.com/"&gt;
 &lt;title&gt;eWorld: eric richardson meets the web&lt;/title&gt;
 &lt;link&gt;http://ericrichardson.com/&lt;/link&gt;
 &lt;description&gt;About 9.4 km away. Near Los Angeles.&lt;/description&gt;
 &lt;geourl:longitude&gt;-118.25201&lt;/geourl:longitude&gt;
 &lt;geourl:latitude&gt;34.0456&lt;/geourl:latitude&gt;
&lt;/item&gt;
(ref [[GeoURL Log: Latitude and longitude data in the RSS feeds - GeoURL (2.0)|http://geourl.org/news/2005/04/26/rssplus.html]])
</code></pre>

<h4><a name="l14"> </a>さらにRSSフィードにGeoTagging</h4>
<p><a href="http://hiki.koshigoe.jp/?%5BFeed%5Dgeourl%A4%C7%C3%CF%CD%FD%BE%F0%CA%F3" class="external">koshigoe hiki - [Feed]geourlで地理情報</a></p>

<h3><a name="l15"><span class="sanchor"> </span></a>GeoRSS</h3>
<p><a href="http://www.georss.org/" class="external">GeoRSS Home</a></p>

<h4><a name="l16"> </a>Simple GeoRSS</h4>
<pre><code>
&lt;georss:point&gt;45.256 -71.92&lt;/georss:point&gt;
</code></pre>

<h4><a name="l17"> </a>GML</h4>
<pre><code>
&lt;georss:where&gt;
 &lt;gml:Point&gt;
  &lt;gml:pos&gt;45.256 -71.92&lt;/gml:pos&gt;
 &lt;/gml:Point&gt;
&lt;/georss:where&gt;
</code></pre>

<p><a href="http://www.opengeospatial.org/groups/?iid=31" class="external">GML</a>はAtom1.0, RSS2.0, RSS1.0での利用を想定していますが、RSS以外の通常のXMLファイルでも使用することができます。</p>

<p><a href="http://www.georss.org/gml.html#examples" class="external">GeoRSS GML Example</a></p>

<h2><span class="date"><a name="l18"> </a></span><span class="title">Google Maps APIでのKML/GeoRSS対応</span></h2>
<p><a href="http://www.google.com/apis/maps/documentation/#XML_Overlays" class="external">KML/GeoRSS Overlays</a>
Google Maps APIでKMLやGeoRSSのファイルを取得して利用するには、GGeoXmlオブジェクトを利用します。GGeoXmlはGOverlayオブジェクトを返します。</p>
<pre><code>
var map = new GMap2(document.getElementById("map")); 
var geoXml = new GGeoXml("http://www.example.com/rss.xml");
map.addOverlay(geoXml);
</code></pre>

<h2><span class="date"><a name="l19"> </a></span><span class="title">参考資料</span></h2>
<ul>
<li><a href="http://googlemapsapi.blogspot.com/2007/03/kml-and-georss-support-added-to-google.html" class="external">Google Maps API Official Blog: KML and GeoRSS Support Added to the Google Maps API</a></li>
<li><a href="http://en.wikipedia.org/wiki/GeoTagging" class="external">GeoTagging - Wikipedia, the free encyclopedia</a></li>
<li><a href="http://en.wikipedia.org/wiki/Geo_%28microformat%29" class="external">Geo (microformat) - Wikipedia, the free encyclopedia</a></li>
<li><a href="http://en.wikipedia.org/wiki/Geocaching" class="external">Geocaching - Wikipedia, the free encyclopedia</a></li>
<li><a href="http://en.wikipedia.org/wiki/Geocoded_photo" class="external">Geocoded photo - Wikipedia, the free encyclopedia</a></li>
<li><a href="http://www.rbbtoday.com/news/20060802/32829.html" class="external">デジカメと持ち歩き、撮影場所を特定できる携帯型のGPSユニット：デジタル家電総合情報サイト：Digital Freak 2006/08/02</a></li>
<li><a href="http://kengo.preston-net.com/archives/002780.shtml" class="external">Going My Way: GeoTagが入力可能になったFlickr</a></li>
<li><a href="http://www.flickr.com/help/screencasts/vol1" class="external">Flickr Help Screencast Volume 1: Geotags &amp; You</a></li>
<li><a href="http://www.flickr.com/groups/geotagging/" class="external">Flickr: GeoTagging Flickr</a></li>
<li><a href="http://www.flickr.com/map/" class="external">Flickr: Explore everyone's geotagged photos on a Map</a></li>
<li><a href="http://www.flickr.com/people/revdancatt/" class="external">Flickr: Rev Dan Catt</a></li>
<li><a href="http://www.geobloggers.com/archives/" class="external">geobloggers</a></li>
<li><a href="http://geourl.org/" class="external">GeoURL (2.0)</a></li>
<li><a href="http://koshigoe.sakura.ne.jp/dokuwiki/doku.php?id=koshigoewiki:feed:geourl" class="external">koshigoewiki:feed:geourl</a></li>
<li><a href="http://postneo.com/icbm/" class="external">ICBM RSS Module</a></li>
<li><a href="http://geourl.org/news/2005/04/26/rssplus.html" class="external">GeoURL Log: Latitude and longitude data in the RSS feeds - GeoURL (2.0)</a></li>
<li><a href="http://hiki.koshigoe.jp/?%5BFeed%5Dgeourl%A4%C7%C3%CF%CD%FD%BE%F0%CA%F3" class="external">koshigoe hiki - [Feed]geourlで地理情報</a></li>
<li><a href="http://www.georss.org/" class="external">GeoRSS Home</a></li>
<li><a href="http://www.opengeospatial.org/groups/?iid=31" class="external">GML</a></li>
<li><a href="http://www.google.com/apis/maps/documentation/#XML_Overlays" class="external">KML/GeoRSS Overlays</a></li>
</ul>