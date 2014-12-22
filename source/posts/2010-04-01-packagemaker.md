---
title: Macアプリのパッケージ作成方法
date: 2010-04-01 11:22 JST
authors: nakano
tags: resume, 
---
MacOSXのアプリケーションはコピーしてインストールが済んでしまうものも多いですが、動作するシステム条件があったり、複数の製品を一度にインストールしたい場合などはインストーラからのインストールが便利です。 今回はインストーラからインストールするために必要となるパッケージの作成方法について説明します。<!--more-->

## アプリケーションの配布

Appleはアプリケーションの配布方法として以下の2つを推奨しています。

### マニュアルインストール
対象のファイルをドラッグ&ドロップなどでインストール先のフォルダにコピーする方法です。コピーするだけなのでとても簡単です。

### インストーラを使ったインストール

インストーラアプリケーションを起動してインストールする方法です。

このインストール方法を利用するとOSやCPUなどのシステム条件を指定したり、インストール先のフォルダの指定、複数のファイルを配置することなど、細かなオプションを設定して自動でインストール作業を行うことができます。

インストーラからインストールするためにはパッケージを作成する必要があります。  

## PackageMaker

パッケージの作成にはPackageMakerを利用します。Xcodeがインストール済みであれば、/Developer/Applications/Utilitiesの下にPackageMaker.appがあります。

今回の説明はバージョン3.0.4を対象にしています。

## パッケージの作成

 ここからはパッケージを作成する手順を説明します。

## プロジェクト作成

まず、PackageMakerを開いてプロジェクトを作成します。

[![100326-0001.png](/images/2010/03/100326-0001.thumbnail.png)](/images/2010/03/100326-0001.png "100326-0001.png")

 

Organization : 逆DNS形式の組織名 Minimum Target : OSのバージョン

## コンテンツを追加する
アプリケーションやドキュメント、Spotlightプラグインなどパッケージに含める製品を追加します。  

メニューの[Project]>[Add Contents]で指定します。

## パッケージコンポーネントの設定

パッケージに含めるそれぞれの製品についての設定です。

### Configuration

[![100120-0002.png](/images/2010/03/100120-0002.thumbnail.png)](/images/2010/03/100120-0002.png "100120-0002.png")

Insatll: インストールするファイル Destination: インストール先のファルダ Allow custom location: インストール先の変更を許可 Package Identifier: パッケージの識別子 Package Version: バージョン番号 Restart Action: 再起動の要求 - None : いらない - Require Logout :  ログアウト - Require Restart : 再起動 - Require Shoutdown : シャットダウン Require admin authentication: 管理者権限が必要  

Allow custom location にチェックを入れるとユーザがインストール時にインストール先を指定できるようになります。

### Contents

[![100120-0003.png](/images/2010/03/100120-0003.thumbnail.png)](/images/2010/03/100120-0003.png "100120-0003.png")

Owner: ファイルのオーナー Group: ファイルのグループ Mode: ファイルのパーミッション File Filters: パッケージに含めないファイルの指定

File Filtersでは正規表現を用いてパッケージに入れたくないファイルやフォルダの指定ができます。 デフォルトでは、.svnやCVSなどが指定されています。

[![100326-0002.png](/images/2010/03/100326-0002.thumbnail.png)](/images/2010/03/100326-0002.png "100326-0002.png")

### Components

[![100121-0001.png](/images/2010/03/100121-0001.thumbnail.png)](/images/2010/03/100121-0001.png "100121-0001.png")

Allow Relocation : インストール後に移動したコンポーネントを探すことを許可 Allow Downgrade : ダウングレードを許可

ダウングレードの判断はConfigurationのPackage Versionで指定してある値から判断されます。

### Scripts

[![100121-0002.png](/images/2010/03/100121-0002.thumbnail.png)](/images/2010/03/100121-0002.png "100121-0002.png")

scripts directory : 実行スクリプトがあるフォルダを指定する Preinstall : インストール前に実行するスクリプト Postinstall : インストール後に実行するスクリプト

スクリプトはシェルスクリプトやperlスクリプトでも可能です。  

MacOSX10.5ではPreinstallとPostinstallの指定したスクリプトしか実行されないようなので注意が必要です。

 

## インストールパッケージの設定
パッケージ全体に関する設定を行ないます。  

### Configuration

[![100121-0003.png](/images/2010/03/100121-0003.thumbnail.png)](/images/2010/03/100121-0003.png "100121-0003.png")

Title : タイトル User Sees : インストールオプション - Easy Install Only :簡易インストールのみ - Custom Install Only : カスタムインストールのみ - Easy and Custom Install : 簡易インストールとカスタムインストールの両方 Install Destination : インストール先 - Volume selected by user : ユーザが選択可能 - System volume : システムのボリュームのみ - User home directory : ホームディレクトリ Description : 概要  

Custom Installにチェックが入っている場合、ユーザがパッケージに入っている製品を選択してインストールしたいものだけをインストールできるようになります。

### Requirements

 システムの条件を指定します。以下、ここで指定できるいくつかの例です。

[![100121-0004.png](/images/2010/03/100121-0004.thumbnail.png)](/images/2010/03/100121-0004.png "100121-0004.png")

Megabytes Available on Target : 空きディスク容量 Maximum CPU Frequency(Hz) : CPUのクロック周波数 Number of CPUs  : CPUの数 USB Device Exists : USBデバイスの有無 Result of Script : 指定したスクリプトの実行結果

Result of Scriptで指定できるように、自前のスクリプトの結果からインストールするかどうかを判断することもできます。  

### Actions

インストール前とインストール後での動作を指定します。

[![100121-0005.png](/images/2010/03/100121-0005.thumbnail.png)](/images/2010/03/100121-0005.png "100121-0005.png")

以下は設定できる項目の例です。

Show File in Finder : ファインダーで指定のパスを開く Open URL : ブラウザで指定のURLを開く Create Alias : エイリアスの作成

[![100121-0006.png](/images/2010/03/100121-0006.thumbnail.png)](/images/2010/03/100121-0006.png "100121-0006.png")

## 選択項目の設定

インストール時にユーザが必要な製品のみインストールできるように選択項目についての設定を行います。

### Configuration

[![100121-0007.png](/images/2010/03/100121-0007.thumbnail.png)](/images/2010/03/100121-0007.png "100121-0007.png")

Choice Name : 選択時の名前 identifier : 選択識別子 initial state デフォルト状態 - Selected : 選択されている - Enabled : 選択変更が可能 - Hidden : ユーザに選択状態を見せない Destination : インストール先 Tooltip : 短かいメッセージの表示 Description : 説明

ここでDestinationを指定した場合、パッケージの設定で指定したインストール先は上書きされるので注意が必要です。  

### Requirements
選択パッケージの個別にシステム条件を設定します。 条件項目については、パッケージ設定のActionsタブ中のものと同じです。

[![100121-0008.png](/images/2010/03/100121-0008.thumbnail.png)](/images/2010/03/100121-0008.png "100121-0008.png")

ここではシステム条件を満たせなかった場合の選択項目の動きを指定できます。

 Selected, Enabled, Hiddenのそれぞれに対して、 - Yes : チェックを入れる - No : チェックを外す - Unchanged : 変更しない  

を設定します。

## インタフェースの編集

インストーラの起動後に表示される背景画像やライセンスの文言などをここで設定します。

[![100122-0001.png](/images/2010/03/100122-0001.thumbnail.png)](/images/2010/03/100122-0001.png "100122-0001.png")

background : 背景画像 Introduction : 前書き Read Me : 注意書き License : ライセンス Finish Up : 完了後のメッセージ

## パッケージのビルド

メニューの[Project] ->[Build and Run]を選択するとパッケージが作成され、インストーラが起動して確認することができます。

 

## おわりに

Macアプリをインストーラからインストールするためのパッケージ作成方法について説明しました。 設定項目がたくさんありますが、パッケージを作ることでユーザはより簡単にインストール作業を行うことができるようになります。

