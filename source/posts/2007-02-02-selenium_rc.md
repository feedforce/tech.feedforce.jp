---
title: Selenium RCの紹介
date: 2007-02-02 18:32 JST
authors: ff_koshigoe
tags: test, resume, 
---
  <h2><span class="date"><a name="l0"> </a></span><span class="title">Selenium RCとは</span></h2>
      <p><a href="http://www.openqa.org/selenium-rc/" class="external">Selenium RC</a>は、<a href="http://www.openqa.org/" class="external">OpenQA</a>によって提供されているSelenium製品ファミリの１つです。<br>

2007/02/02現在、<a href="http://www.apache.org/licenses/LICENSE-2.0" class="external">Apache License, Version 2.0</a>の下に配布されています。</p>
<p>Selenium RCは、<strong>Selenium Remote Control</strong>という名が表すとおり、Seleniumテストを遠隔操作するための製品です。<br>
これは、JAVAの<a href="http://www.mortbay.org/" class="external">Jetty Web Server</a>を利用した<strong>Selenium Server</strong>を利用して実現されています。</p>
<!--more-->  
  <div><div class="day">

  <div class="body">
    <div class="section">
      <ul>
<li><a href="#l0">Selenium RCとは</a></li>
<li><a href="#l1">準備</a></li>
<ul>
<li><a href="#l2">Selenium RC</a></li>
<li><a href="#l3">PHPUnit3.0</a></li>

</ul>
<li><a href="#l4">インタラクティブモードで実行</a></li>
<li><a href="#l5">PHPUnitから実行</a></li>
<ul>
<li><a href="#l6">Selenium Serverをデーモンとして実行</a></li>
<li><a href="#l7">サンプルコード</a></li>
<ul>
<li><a href="#l8">実行</a></li>
</ul>
</ul>
<li><a href="#l9">さいごに</a></li>

</ul>

    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l0"> </a></span><span class="title">Selenium RCとは</span></h2>
  <div class="body">
    <div class="section">
      <p><a href="http://www.openqa.org/selenium-rc/" class="external">Selenium RC</a>は、<a href="http://www.openqa.org/" class="external">OpenQA</a>によって提供されているSelenium製品ファミリの１つです。<br>

2007/02/02現在、<a href="http://www.apache.org/licenses/LICENSE-2.0" class="external">Apache License, Version 2.0</a>の下に配布されています。</p>
<p>Selenium RCは、<strong>Selenium Remote Control</strong>という名が表すとおり、Seleniumテストを遠隔操作するための製品です。<br>
これは、JAVAの<a href="http://www.mortbay.org/" class="external">Jetty Web Server</a>を利用した<strong>Selenium Server</strong>を利用して実現されています。</p>
```

/---------------------\\      /------------------------\\
|                     |      |                        |
| /-----------------\\ | HTTP | /--------------------\\ |
| | Selenium Server |-+------+-| Selenium RC Driver | |
| \\-----------------/ |      | \\--------------------/ |
|      |      |       |      |       |        |       |
| /-----------------\\ |      | /--------------------\\ |
| |   Web Browser   | |      | |      Program       | |
| \\-----------------/ |      | \\--------------------/ |
|                     |      |                        |
\\---------------------/      \\------------------------/

```

    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l1"> </a></span><span class="title">準備</span></h2>
  <div class="body">
    <div class="section">
      <h3><a name="l2"><span class="sanchor"> </span></a>Selenium RC</h3>

<p>Selenium RCの実行には、以下の環境が必要です(今回は、Windodwsマシン上で実行します)。</p>
<ul>
<li>JRE(Java Runtime Environment) version 1.5.0以上</li>
<li>Seleniumテストを実行するウェブブラウザ</li>
</ul>
<ol>
<li>JRE1.5.0以上の環境を用意<ol>
<li>今回の環境では1.5.0_10-b03を利用しました</li>
</ol></li>
<li><a href="http://www.openqa.org/selenium-rc/download.action" class="external">Selenium Remote Control: Downloads</a>から最新版をダウンロード<ol>

<li>2007/02/02現在、v0.9.0</li>
</ol></li>
<li>ダウンロードした圧縮ファイルを適当な場所に展開(DOSプロンプトから実行しやすい位置がおすすめです)<ol>
<li>今回はC:\selenium-remote-control-0.9.0に展開しました</li>
</ol></li>
</ol>
<h3><a name="l3"><span class="sanchor"> </span></a>PHPUnit3.0</h3>
<p>今回は、PHPUnitから実行するために、以下の環境も用意します。PHPUnitは、Selenium Serverとは別のマシンで実行することにします(同一マシンで実行することも出来ます)。</p>
<ul>
<li>PHP5.1以上</li>

<li>PHPUnit3.x</li>
<li>PEAR::Testing_Selenium-beta</li>
</ul>
<ol>
<li>PHP5.1.0以上の環境を用意</li>
<li>Testing_Selenium(beta)をインストール<ol>
<li>2007/02/02現在、v0.3.0</li>
</ol></li>
<li>PHPUnit3をインストール<ol>
<li>2007/02/02現在、v3.0.3</li>

<li>参考<a href="http://www.phpunit.de/pocket_guide/3.0/ja/installation.html" class="external">第3章 PHPUnit のインストール</a></li>
<li>過去のPHPUnit(v1,v2)をアンインストールするする必要があります</li>
</ol></li>
</ol>
```

$ pear install -a Testing_Selenium-beta
$ pear channel-discover pear.phpunit.de
$ pear install -a phpunit/PHPUnit

```
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l4"> </a></span><span class="title">インタラクティブモードで実行</span></h2>

  <div class="body">
    <div class="section">
      <ul>
<li>参考<a href="http://www.openqa.org/selenium-rc/tutorial.html" class="external">Selenium Remote Control: Tutorial</a></li>
</ul>
<p>Selenium Serverは、デーモン起動のほかにインタラクティブモードでの起動が可能です。まず、動作を見るためにインタラクティブモードで実行してみます。<br>
<strong>server\selenium-server.jar</strong>が、Selenium Serverです。これを、<strong>java -jar</strong>で実行します。</p>

<ul>
<li>(DOS)はDOSプロンプト</li>
<li>(SRC)はSelenium Serverの入力待ち</li>
<li>何も無ければメッセージ表示</li>
</ul>
<p>インタラクティブモードで起動し、以下の手順を実行します。</p>
<ul>
<li>ブラウザと起点URLを指定してセッションを準備<ul>
<li>指定したブラウザが起動して、以降のコマンド実行に必要なセッションIDを取得します</li>
</ul></li>
<li>Googleを開く</li>

<li>検索キーワードを入力(SeleniumRC)</li>
<li>titleタグの内容を取得する</li>
<li>テストを終了してブラウザを閉じる</li>
<li>Selenium Server終了</li>
</ul>
```

(DOS)C:\~&gt; java -jar C:\selenium-remote-control-0.9.0\server/selenium-server.jar -interactive
... 起動メッセージ...
(SRC)cmd=getNewBrowserSession&amp;1=*iexplore&amp;2=http://www.google.com
... 実行メッセージ ...
Got result: OK,221234 on session 221234
(SRC)cmd=open&amp;1=http://www.google.com/webhp&amp;sessionId=221234
... 実行メッセージ ...
(SRC)cmd=type&amp;1=q&amp;2=SeleniumRC&amp;sessionId=221234
... 実行メッセージ ...
(SRC)cmd=click&amp;1=btnG&amp;sessionId=221234
... 実行メッセージ ...
(SRC)cmd=getTitle&amp;sessionId=221234
... 実行メッセージ ...
Got result: OK,SeleniumRC - Google 検索 on session 221234
(SRC)cmd=testComplete&amp;sessionId=221234
... 実行メッセージ ...
(SRC)^C
Shutting down...
(DOS)C:\~&gt;


```
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l5"> </a></span><span class="title">PHPUnitから実行</span></h2>
  <div class="body">
    <div class="section">
      <p>Testing_SeleniumというPEARパッケージを利用することで、PHPUnitからSeleniumテストをリモートマシン上で実行することが可能です。<br>

インタラクティブモードで実行した内容をPHPUnitのテストケースにして実行します。</p>
<h3><a name="l6"><span class="sanchor"> </span></a>Selenium Serverをデーモンとして実行</h3>
<p>テスト実行の前に、Selenium Serverをデーモンとして起動しておきます。<br></p>
```

(HOST[A]/DOS)C:\~&gt; java -jar C:\selenium-remote-control-0.9.0\server/selenium-server.jar

```
<h3><a name="l7"><span class="sanchor"> </span></a>サンプルコード</h3>
<dl>
<dt>SeleniumRCTest.php(UTF-8)</dt>

</dl>
```

&lt;?php
require_once 'PHPUnit/Extensions/SeleniumTestCase.php';

class SeleniumRCTest extends PHPUnit_Extensions_SeleniumTestCase
{
    protected function setUp()
    {
        $this-&gt;setHost('192.168.1.77'); // HOST[A]のIP
        $this-&gt;setBrowser('*iexplore');
        $this-&gt;setBrowserUrl('http://www.google.com/');
    }

    public function testTitle()
    {
        $this-&gt;open('/webhp');
        $this-&gt;type('q', 'SeleniumRC');
        $this-&gt;click('btnG');
        $this-&gt;waitForPageToLoad(30000);
        $this-&gt;assertTitleEquals('SeleniumRC - Google 検索');
    }
}

?&gt;

```
<h4><a name="l8"> </a>実行</h4>
```


(HOST[B]/DOS)C:\~&gt; phpunit path\to\SeleniumRCTest.php
PHPUnit 3.0.3 by Sebastian Bergmann.

.

Time: 00:12

OK (1 test)

```
<p>HOST[B]上のDOSプロンプトからphpunitコマンドでテストケースファイルを実行すると、HOST[A]上で起動させたSelenium Serverにリクエストを行い、HOST[A]上でブラウザを立ち上げSeleniumテストが実行されます。</p>
    </div>
  </div>
</div>
<div class="day">
  <h2><span class="date"><a name="l9"> </a></span><span class="title">さいごに</span></h2>
  <div class="body">

    <div class="section">
      <p>今回の資料の中では、Selenium Serverの起動オプションについては省略しています。</p>
<p>以下のように、<strong>-help</strong>オプションをつけて実行することでヘルプが表示されます。</p>
```

(DOS)C:\~&gt;java -jar c:\selenium-remote-control-0.9.0\server\selenium-server.jar -help

```
<p>HTMLで記述したテストスイートを利用するオプションや、マルチウィンドウモードでテストを実行するオプション、Selenium Serverのポートやタイムアウトを設定するオプションなどがあります。ほかにも、実運用の際に役立ちそうなオプションがあるので、試してみてはいかがでしょうか。</p>
<p>また、いくつか既知の問題もあるようですので、問題にぶつかった際は以下のページなどを参考にしてください。</p>

<ul>
<li><a href="http://www.openqa.org/selenium-rc/troubleshooting.html" class="external">Selenium Remote Control: Troubleshooting FAQ</a></li>
</ul>
    </div>
  </div>
</div>
</div>
