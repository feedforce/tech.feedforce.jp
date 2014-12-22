---
title: Selenium RCの紹介
date: 2007-02-02 18:32 JST
authors: ff_koshigoe
tags: test, resume, 
---
## Selenium RCとは

[Selenium RC](http://www.openqa.org/selenium-rc/)は、 [OpenQA](http://www.openqa.org/)によって提供されているSelenium製品ファミリの１つです。  

2007/02/02現在、 [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)の下に配布されています。

Selenium RCは、 **Selenium Remote Control** という名が表すとおり、Seleniumテストを遠隔操作するための製品です。  
これは、JAVAの [Jetty Web Server](http://www.mortbay.org/)を利用した **Selenium Server** を利用して実現されています。

<!--more-->

- Selenium RCとは

- 準備

  - Selenium RC

  - PHPUnit3.0

- インタラクティブモードで実行

- PHPUnitから実行

  - Selenium Serverをデーモンとして実行

  - サンプルコード

    - 実行

- さいごに

## Selenium RCとは

[Selenium RC](http://www.openqa.org/selenium-rc/)は、 [OpenQA](http://www.openqa.org/)によって提供されているSelenium製品ファミリの１つです。  

2007/02/02現在、 [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)の下に配布されています。

Selenium RCは、 **Selenium Remote Control** という名が表すとおり、Seleniumテストを遠隔操作するための製品です。  
これは、JAVAの [Jetty Web Server](http://www.mortbay.org/)を利用した **Selenium Server** を利用して実現されています。

```
/---------------------\\ /------------------------\\
| | | |
| /-----------------\\ | HTTP | /--------------------\\ |
| | Selenium Server |-+------+-| Selenium RC Driver | |
| \\-----------------/ | | \\--------------------/ |
| | | | | | | |
| /-----------------\\ | | /--------------------\\ |
| | Web Browser | | | | Program | |
| \\-----------------/ | | \\--------------------/ |
| | | |
\\---------------------/ \\------------------------/
```

## 準備

### Selenium RC

Selenium RCの実行には、以下の環境が必要です(今回は、Windodwsマシン上で実行します)。

- JRE(Java Runtime Environment) version 1.5.0以上
- Seleniumテストを実行するウェブブラウザ

1. JRE1.5.0以上の環境を用意
  1. 今回の環境では1.5.0\_10-b03を利用しました
2. [Selenium Remote Control: Downloads](http://www.openqa.org/selenium-rc/download.action)から最新版をダウンロード
  1. 2007/02/02現在、v0.9.0
3. ダウンロードした圧縮ファイルを適当な場所に展開(DOSプロンプトから実行しやすい位置がおすすめです)
  1. 今回はC:\selenium-remote-control-0.9.0に展開しました

### PHPUnit3.0

今回は、PHPUnitから実行するために、以下の環境も用意します。PHPUnitは、Selenium Serverとは別のマシンで実行することにします(同一マシンで実行することも出来ます)。

- PHP5.1以上
- PHPUnit3.x
- PEAR::Testing\_Selenium-beta

1. PHP5.1.0以上の環境を用意
2. Testing\_Selenium(beta)をインストール
  1. 2007/02/02現在、v0.3.0
3. PHPUnit3をインストール
  1. 2007/02/02現在、v3.0.3
  2. 参考 [第3章 PHPUnit のインストール](http://www.phpunit.de/pocket_guide/3.0/ja/installation.html)
  3. 過去のPHPUnit(v1,v2)をアンインストールするする必要があります

```
$ pear install -a Testing_Selenium-beta
$ pear channel-discover pear.phpunit.de
$ pear install -a phpunit/PHPUnit
```

## インタラクティブモードで実行

- 参考 [Selenium Remote Control: Tutorial](http://www.openqa.org/selenium-rc/tutorial.html)

Selenium Serverは、デーモン起動のほかにインタラクティブモードでの起動が可能です。まず、動作を見るためにインタラクティブモードで実行してみます。  

**server\selenium-server.jar** が、Selenium Serverです。これを、 **java -jar** で実行します。

- (DOS)はDOSプロンプト
- (SRC)はSelenium Serverの入力待ち
- 何も無ければメッセージ表示

インタラクティブモードで起動し、以下の手順を実行します。

- ブラウザと起点URLを指定してセッションを準備
  - 指定したブラウザが起動して、以降のコマンド実行に必要なセッションIDを取得します
- Googleを開く
- 検索キーワードを入力(SeleniumRC)
- titleタグの内容を取得する
- テストを終了してブラウザを閉じる
- Selenium Server終了

```
(DOS)C:\~> java -jar C:\selenium-remote-control-0.9.0\server/selenium-server.jar -interactive
... 起動メッセージ...
(SRC)cmd=getNewBrowserSession&1=*iexplore&2=http://www.google.com
... 実行メッセージ ...
Got result: OK,221234 on session 221234
(SRC)cmd=open&1=http://www.google.com/webhp&sessionId=221234
... 実行メッセージ ...
(SRC)cmd=type&1=q&2=SeleniumRC&sessionId=221234
... 実行メッセージ ...
(SRC)cmd=click&1=btnG&sessionId=221234
... 実行メッセージ ...
(SRC)cmd=getTitle&sessionId=221234
... 実行メッセージ ...
Got result: OK,SeleniumRC - Google 検索 on session 221234
(SRC)cmd=testComplete&sessionId=221234
... 実行メッセージ ...
(SRC)^C
Shutting down...
(DOS)C:\~>

```

## PHPUnitから実行

Testing\_SeleniumというPEARパッケージを利用することで、PHPUnitからSeleniumテストをリモートマシン上で実行することが可能です。  

インタラクティブモードで実行した内容をPHPUnitのテストケースにして実行します。

### Selenium Serverをデーモンとして実行

テスト実行の前に、Selenium Serverをデーモンとして起動しておきます。

```
(HOST[A]/DOS)C:\~> java -jar C:\selenium-remote-control-0.9.0\server/selenium-server.jar
```

### サンプルコード

<dl>
<dt>SeleniumRCTest.php(UTF-8)</dt>
</dl>

```php
<?php
require_once 'PHPUnit/Extensions/SeleniumTestCase.php';

class SeleniumRCTest extends PHPUnit_Extensions_SeleniumTestCase
{
    protected function setUp()
    {
        $this->setHost('192.168.1.77'); // HOST[A]のIP
        $this->setBrowser('*iexplore');
        $this->setBrowserUrl('http://www.google.com/');
    }

 public function testTitle()
    {
        $this->open('/webhp');
        $this->type('q', 'SeleniumRC');
        $this->click('btnG');
        $this->waitForPageToLoad(30000);
        $this->assertTitleEquals('SeleniumRC - Google 検索');
    }
}

?>
```

#### 実行

```
(HOST[B]/DOS)C:\~> phpunit path\to\SeleniumRCTest.php
PHPUnit 3.0.3 by Sebastian Bergmann.

.

Time: 00:12

OK (1 test)
```

HOST[B]上のDOSプロンプトからphpunitコマンドでテストケースファイルを実行すると、HOST[A]上で起動させたSelenium Serverにリクエストを行い、HOST[A]上でブラウザを立ち上げSeleniumテストが実行されます。

## さいごに

今回の資料の中では、Selenium Serverの起動オプションについては省略しています。

以下のように、 **-help** オプションをつけて実行することでヘルプが表示されます。

```
(DOS)C:\~>java -jar c:\selenium-remote-control-0.9.0\server\selenium-server.jar -help
```

HTMLで記述したテストスイートを利用するオプションや、マルチウィンドウモードでテストを実行するオプション、Selenium Serverのポートやタイムアウトを設定するオプションなどがあります。ほかにも、実運用の際に役立ちそうなオプションがあるので、試してみてはいかがでしょうか。

また、いくつか既知の問題もあるようですので、問題にぶつかった際は以下のページなどを参考にしてください。

- [Selenium Remote Control: Troubleshooting FAQ](http://www.openqa.org/selenium-rc/troubleshooting.html)

