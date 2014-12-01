---
title: RubyCocoaを1杯
date: 2008-07-02 18:43 JST
authors: nakano
tags: ruby, resume, 
---
<span class="Apple-style-span" style="font-family: Times; line-height: normal"> </span>
<p style="padding: 0.5em; background-color: #ffffff; font-family: Georgia,'Times New Roman',Times,serif; font-style: normal; font-variant: normal; font-weight: normal; font-size: 1em; line-height: 1.3em; font-size-adjust: none; font-stretch: normal" align="justify">今回はRubyCocoaを使ってMacOSXの簡単なアプリケーションを作ってみようと思います。<span id="more-75"></span></p>
<!--more-->
<h2><span class="Apple-style-span" style="font-size: 16px; font-weight: normal"><span class="Apple-style-span" style="font-size: 24px; font-weight: bold">RubyCocoaとは</span></span></h2>
<ul>
	<li>Rubyを使ってMacOSXのアプリケーションフレームワークであるCocoaを操作できる</li>
	<li>対話的にCocoaを開発できる</li>
	<li>Leopardから標準搭載</li>
	<li>バージョン 0.13.2(2008/2/16)</li>
</ul>
<h2><span class="Apple-style-span" style="font-size: 16px; font-weight: normal"><span class="Apple-style-span" style="font-size: 24px; font-weight: bold">代表的なアプリケーション</span></span></h2>
<p align="justify">RubyCocoaを使って開発されたアプリケーションには以下のようなものがあります。</p>

<ul>
	<li><a href="http://limechat.sourceforge.net/index_ja.html">LimeChat for OSX</a></li>
	<li><a href="http://coderepos.org/share/wiki/Chemr">Chemr</a></li>
	<li><a href="http://blog.deadbeaf.org/2008/03/01/qstwitter-14/">QSTwitter
</a></li>
</ul>
<p align="justify">特にQuickSilverからTwitterに投げれるQSTwitterはとても便利に使わせてもらっています。</p>

<h2>作ってみよう</h2>
<p align="justify">Twitterにポストするだけの簡単なアプリケーションを作ってみます。</p>

<h2><font class="Apple-style-span" size="6"><span class="Apple-style-span" style="font-size: 19px">準備</span></font></h2>
<p align="justify">Xcodeを使うので、あらかじめインストールしておく必要があります。MacOSXのインストールDVDに含まれているのでそこからインストールするか、もしくは<a href="http://developer.apple.com/">ADC</a>(Apple Developer Connection)のサイトからダウンロードすることもできます。また、RubyからTwitterにポストする部分でRuby Twitter Gemを使いましたので、それもインストールしておきます。 ターミナルを開いて、</p>

<pre style="font-family: 'Courier New',fixed; font-size: 11px; line-height: 13px">$ sudo gem install twitter</code></pre>
でインストールします。
<h2><font class="Apple-style-span" size="6"><span class="Apple-style-span" style="font-size: 19px">プロジェクト作成</span></font></h2>
<p align="justify">まず、プロジェクトを作成します。/Developer/Applications/Xcode.appを開きます。 File-&gt;New Projectを選択し、 Cocoa-Ruby Applicationを選択します(1)。</p>
<p align="justify"><a href="/images/2008/06/2008-06-26_0029.png" title="new project"><img src="/images/2008/06/2008-06-26_0029.thumbnail.png" alt="new project" /></a> (1)</p>
プロジェクト名を入力して次に進むと、プロジェクトウィンドウが立ちあがります(2)。
<p align="justify"><a href="/images/2008/06/2008-06-26_0031.png" title="プロジェクトウィンドウ"><img src="/images/2008/06/2008-06-26_0031.thumbnail.png" alt="プロジェクトウィンドウ" /></a> (2)</p>
次にコントローラを作成します。 Classes-&gt;Add-&gt;Ruby NSObject subclass を選択します(3)。

<p align="justify"> <a href="/images/2008/06/2008-06-26_0032.png" title="Ruby NSObject subclass"><img src="/images/2008/06/2008-06-26_0032.thumbnail.png" alt="Ruby NSObject subclass" /></a> (3)
ここではAppController.rbというファイル名で保存します。 今回は次のようなコードにしました。
<pre><code>require 'osx/cocoa'
require 'rubygems'
require 'twitter'

class AppController &lt; OSX::NSObject
  include OSX
  ib_outlet :window, :name, :password, :message
  ib_action :post
  def post
    twit = Twitter::Base.new(@name.stringValue.to_s, @password.stringValue.to_s)
    twit.update(@message.stringValue.to_s)
    @message.setStringValue ''
  end
end</code></pre>
<p align="justify"> ib_outletで、コントローラからウィンドウへの参照を定義しています。 ib_actionで、アクションを定義します。</p>
ボタンがクリックされたときにここで定義したアクシ ョンが呼ばれるように後で設定します。
def post … end にアクションpostの処理内容を書きます。 Twitterクラスのインスタンスを生成し、ウィンドウに入力してあるメッセージをポストします。@nameで参照しているオブジェクトを取得し、stringValueメソッドでそのオブジェクトの文字列を取得します。 stringValueで取得した文字列はCocoaの文字列クラスのオブジェクトなので、to_sメソッドで Rubyの文字列に変換しています。
<p align="justify"> setStringValueメソッドで、参照しているオブジェクトの文字列に文字を設定しています。</p>
<p align="justify">このコードを保存し、次にInterfaceBuilderを使ってUIとコントローラを結びつけていきます。 プロジェクトウィンドウのMainMenu.nibをダブルクリックする(4)とInterfaceBuilderが立ち上がります。</p>
 <a href="/images/2008/06/mainmenunib.png" title="mainmenunib.png"><img src="/images/2008/06/mainmenunib.thumbnail.png" alt="mainmenunib.png" /></a> (4)
LibraryパレットからNSObjectをドラッグし、メインウィンドウにドロップします(5)。

<p align="justify"><a href="/images/2008/06/movensobject.png" title="movensobject.png"><img src="/images/2008/06/movensobject.thumbnail.png" alt="movensobject.png" /></a> (5)
このオブジェクトを選択した状態で、クラスパレットのClassに先程作成したAppControllerを選択します(6)。

<p align="justify"> <a href="/images/2008/06/selectappcontroller.png" title="selectappcontroller.png"><img src="/images/2008/06/selectappcontroller.thumbnail.png" alt="selectappcontroller.png" /></a> (6)
次にWindowとコントローラを結びつけていきます。今回は元々あるWindowは使わないので、メインウィンドウにあるWindowを削除します。
LibraryパレットからHUD Windowをドラッグ&amp;ドロップでメインウィンドウに移動します(7)。

<a href="/images/2008/06/hudwindow.png" title="hudwindow.png"><img src="/images/2008/06/hudwindow.thumbnail.png" alt="hudwindow.png" /></a> (7)

このウィンドウとコントローラを結びつけるために、メインウィンドウのAppControllerをCtrlキーを押したままマウスを押し、Windowにドラッグして離します。
<p align="justify"><a href="/images/2008/06/picture-5.png" title="picture-5.png"><img src="/images/2008/06/picture-5.thumbnail.png" alt="picture-5.png" /></a> (8)</p>

<p align="justify"> Outletsというウィンドウが表示されるので、AppController.rbのib_outletに定義した windowを選択します(8)。次に、Twitterにポストするために必要なボタンやテキストフィールドを追加していきます。
メインウィンドウのPanel(Window)をダブルクリックするとそのウィンドウが表示されるので、そこにパネルウィンドウから必要なオブジェクトをドラッグ&amp;ドロップで配置していきます(9)。今回は、PushButtonとTextField,Secure TextField, Labelを使いました。

<p align="justify"><a href="/images/2008/06/windowbottun.png" title="windowbottun.png"><img src="/images/2008/06/windowbottun.thumbnail.png" alt="windowbottun.png" /></a> (9)
配置したテキストフィールドやボタンとコントローラを結びつけていきます。
メインウィンドウのAppControllerを選択し、Ctrlキーを押したままマウスを押してウィンドウのオブジェクトにドラッグして離します。すると、選択肢にAppController.rbで定義したアウトレットが表示されるので、対応するものを選択します(10)。

<p align="justify"><a href="/images/2008/06/picture-6.png" title="picture-6.png"><img src="/images/2008/06/picture-6.thumbnail.png" alt="picture-6.png" /></a> (10)
messageやname,passwordの部分をこのように設定していきます。
次はTwitterにポストする時に押すボタンとコントローラを結びつけます。
アウトレットの時とは逆に、ボタンを選択しCtrlキーを押したままマウスを押してメインウィンドウのAppControllerにドラッグして離します(11)。
このとき、AppController.rbのib_actionに定義した「post」が表示されるので、選択します。

<p align="justify"><a href="/images/2008/06/picture-7.png" title="picture-7.png"><img src="/images/2008/06/picture-7.thumbnail.png" alt="picture-7.png" /></a> (11)
ウィンドウのオブジェクトをすべてコントローラと結びつけたら、実行してみます。
Xcodeのメニューにある、Build -&gt; Build and Go で実行するとアプリケーションが立ち上がります(12)。
<p align="justify"> <a href="/images/2008/06/rctwitter.png" title="rctwitter.png"><img src="/images/2008/06/rctwitter.thumbnail.png" alt="rctwitter.png" /></a> (12)</p>
<p align="justify"> Twitterのアカウント情報を入力し、Postボタンを押してMessageを投げることができれば成功です。</p>

<h2>おわりに</h2>
<p align="justify"> 細かな処理は省略しましたが、RubyCocoaを使ってアプリケーションを作る大まかな流れはつかめたと思います。
アカウント情報が間違っていた場合の例外処理や、そもそも設定部分は環境設定画面に置くなど、まだまだやることはたくさんありそうです。
