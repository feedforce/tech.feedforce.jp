---
title: RubyCocoaを1杯
date: 2008-07-02 18:43 JST
authors: nakano
tags: ruby, resume, 
---
   

今回はRubyCocoaを使ってMacOSXの簡単なアプリケーションを作ってみようと思います。

<!--more-->  

## RubyCocoaとは

- Rubyを使ってMacOSXのアプリケーションフレームワークであるCocoaを操作できる
- 対話的にCocoaを開発できる
- Leopardから標準搭載
- バージョン 0.13.2(2008/2/16)

## 代表的なアプリケーション

RubyCocoaを使って開発されたアプリケーションには以下のようなものがあります。

- [LimeChat for OSX](http://limechat.sourceforge.net/index_ja.html)
- [Chemr](http://coderepos.org/share/wiki/Chemr)
- [QSTwitter  

](http://blog.deadbeaf.org/2008/03/01/qstwitter-14/)

特にQuickSilverからTwitterに投げれるQSTwitterはとても便利に使わせてもらっています。

## 作ってみよう

Twitterにポストするだけの簡単なアプリケーションを作ってみます。

## <font class="Apple-style-span" size="6"><span class="Apple-style-span" style="font-size: 19px">準備</span></font>

Xcodeを使うので、あらかじめインストールしておく必要があります。MacOSXのインストールDVDに含まれているのでそこからインストールするか、もしくは [ADC](http://developer.apple.com/)(Apple Developer Connection)のサイトからダウンロードすることもできます。また、RubyからTwitterにポストする部分でRuby Twitter Gemを使いましたので、それもインストールしておきます。 ターミナルを開いて、

```
$ sudo gem install twitter
```
でインストールします。  

## <font class="Apple-style-span" size="6"><span class="Apple-style-span" style="font-size: 19px">プロジェクト作成</span></font>

まず、プロジェクトを作成します。/Developer/Applications/Xcode.appを開きます。 File->New Projectを選択し、 Cocoa-Ruby Applicationを選択します(1)。

[![new project](/images/2008/06/2008-06-26_0029.thumbnail.png)](/images/2008/06/2008-06-26_0029.png "new project") (1)

プロジェクト名を入力して次に進むと、プロジェクトウィンドウが立ちあがります(2)。  

[![プロジェクトウィンドウ](/images/2008/06/2008-06-26_0031.thumbnail.png)](/images/2008/06/2008-06-26_0031.png "プロジェクトウィンドウ") (2)

次にコントローラを作成します。 Classes->Add->Ruby NSObject subclass を選択します(3)。

[![Ruby NSObject subclass](/images/2008/06/2008-06-26_0032.thumbnail.png)](/images/2008/06/2008-06-26_0032.png "Ruby NSObject subclass") (3) ここではAppController.rbというファイル名で保存します。 今回は次のようなコードにしました。

```
require 'osx/cocoa'
require 'rubygems'
require 'twitter'

class AppController < OSX::NSObject
  include OSX
  ib_outlet :window, :name, :password, :message
  ib_action :post
  def post
    twit = Twitter::Base.new(@name.stringValue.to_s, @password.stringValue.to_s)
    twit.update(@message.stringValue.to_s)
    @message.setStringValue ''
  end
end
```

ib\_outletで、コントローラからウィンドウへの参照を定義しています。 ib\_actionで、アクションを定義します。

ボタンがクリックされたときにここで定義したアクシ ョンが呼ばれるように後で設定します。 def post … end にアクションpostの処理内容を書きます。 Twitterクラスのインスタンスを生成し、ウィンドウに入力してあるメッセージをポストします。@nameで参照しているオブジェクトを取得し、stringValueメソッドでそのオブジェクトの文字列を取得します。 stringValueで取得した文字列はCocoaの文字列クラスのオブジェクトなので、to\_sメソッドで Rubyの文字列に変換しています。  

setStringValueメソッドで、参照しているオブジェクトの文字列に文字を設定しています。

このコードを保存し、次にInterfaceBuilderを使ってUIとコントローラを結びつけていきます。 プロジェクトウィンドウのMainMenu.nibをダブルクリックする(4)とInterfaceBuilderが立ち上がります。

[![mainmenunib.png](/images/2008/06/mainmenunib.thumbnail.png)](/images/2008/06/mainmenunib.png "mainmenunib.png") (4) LibraryパレットからNSObjectをドラッグし、メインウィンドウにドロップします(5)。

[![movensobject.png](/images/2008/06/movensobject.thumbnail.png)](/images/2008/06/movensobject.png "movensobject.png") (5) このオブジェクトを選択した状態で、クラスパレットのClassに先程作成したAppControllerを選択します(6)。

[![selectappcontroller.png](/images/2008/06/selectappcontroller.thumbnail.png)](/images/2008/06/selectappcontroller.png "selectappcontroller.png") (6) 次にWindowとコントローラを結びつけていきます。今回は元々あるWindowは使わないので、メインウィンドウにあるWindowを削除します。 LibraryパレットからHUD Windowをドラッグ&ドロップでメインウィンドウに移動します(7)。

[![hudwindow.png](/images/2008/06/hudwindow.thumbnail.png)](/images/2008/06/hudwindow.png "hudwindow.png") (7)

このウィンドウとコントローラを結びつけるために、メインウィンドウのAppControllerをCtrlキーを押したままマウスを押し、Windowにドラッグして離します。

[![picture-5.png](/images/2008/06/picture-5.thumbnail.png)](/images/2008/06/picture-5.png "picture-5.png") (8)

Outletsというウィンドウが表示されるので、AppController.rbのib\_outletに定義した windowを選択します(8)。次に、Twitterにポストするために必要なボタンやテキストフィールドを追加していきます。 メインウィンドウのPanel(Window)をダブルクリックするとそのウィンドウが表示されるので、そこにパネルウィンドウから必要なオブジェクトをドラッグ&ドロップで配置していきます(9)。今回は、PushButtonとTextField,Secure TextField, Labelを使いました。

[![windowbottun.png](/images/2008/06/windowbottun.thumbnail.png)](/images/2008/06/windowbottun.png "windowbottun.png") (9) 配置したテキストフィールドやボタンとコントローラを結びつけていきます。 メインウィンドウのAppControllerを選択し、Ctrlキーを押したままマウスを押してウィンドウのオブジェクトにドラッグして離します。すると、選択肢にAppController.rbで定義したアウトレットが表示されるので、対応するものを選択します(10)。

[![picture-6.png](/images/2008/06/picture-6.thumbnail.png)](/images/2008/06/picture-6.png "picture-6.png") (10) messageやname,passwordの部分をこのように設定していきます。 次はTwitterにポストする時に押すボタンとコントローラを結びつけます。 アウトレットの時とは逆に、ボタンを選択しCtrlキーを押したままマウスを押してメインウィンドウのAppControllerにドラッグして離します(11)。 このとき、AppController.rbのib\_actionに定義した「post」が表示されるので、選択します。

[![picture-7.png](/images/2008/06/picture-7.thumbnail.png)](/images/2008/06/picture-7.png "picture-7.png") (11) ウィンドウのオブジェクトをすべてコントローラと結びつけたら、実行してみます。 Xcodeのメニューにある、Build -> Build and Go で実行するとアプリケーションが立ち上がります(12)。

[![rctwitter.png](/images/2008/06/rctwitter.thumbnail.png)](/images/2008/06/rctwitter.png "rctwitter.png") (12)

Twitterのアカウント情報を入力し、Postボタンを押してMessageを投げることができれば成功です。

## おわりに

細かな処理は省略しましたが、RubyCocoaを使ってアプリケーションを作る大まかな流れはつかめたと思います。 アカウント情報が間違っていた場合の例外処理や、そもそも設定部分は環境設定画面に置くなど、まだまだやることはたくさんありそうです。

