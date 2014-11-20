---
title: Easy-Mmodeを使ってEmacsのマイナーモードを作る
date: 2008-12-12 19:01 JST
authors: nakano
tags: resume, 
---
<p align="justify">今回はEmacsのマイナーモードを作成する手順を紹介します。</p>
説明では弊社が提供しているプロダクトのひとつ <a href="http://www.rsssuite.jp" title="RSS Suite" target="_blank">RSS Suite</a> で利用している独自フレームワーク中で、対応するファイル間を移動できるようにするマイナーモードを作成していきます。
<!--more-->
<h3>メジャーモードとマイナーモード</h3>
Emacsにはカスタマイズする定義の集まりであるモードというものがあり、メジャーモードとマイナーモードの2種類があります。
<h4>メジャーモード</h4>
特定のテキスト編集向けに特化している。各バッファには、ある時点で1つのメジャーモードしかない。
<h4>マイナーモード</h4>
メジャーモードの選択とは独立にオン/オフできる機能を提供する。
ここではマイナーモードを作成します。
<h3>バッファとウィンドウ</h3>
Emacs内でファイル間を移動するには、ウィンドウとバッファの操作が必要になります。
<h4 align="justify">バッファ</h4>
編集領域。Emacsの編集操作はすべてバッファを対象に行われます。
<h4 align="justify">ウィンドウ</h4>
<p align="justify"> バッファの表示領域のこと。</p>

<h3>Easy-Mmode</h3>
単純なマイナーモードであればEasy-Mmodeパッケージを利用すると便利です。
以下のように書くと、test-modeというマイナーモードを定義できます。
<pre><code> ;; マイナーモードの定義
 (easy-mmode-define-minor-mode test-mode
 ;; モード名は、-mode
 ;; ドキュメント
   "This is Test Mode."
 ;; 初期値
 nil
 ;; on の時のモード行への表示
 " TestMode"
 ;; マイナーモード用キーマップの初期値
 '(("C-cf" . test-function))</code></pre>
「M-x test-mode」でモードのオン/オフを切り替えることができ、test-modeがオンの時はキーバインド「C-c f」で関数test-functionを呼び出すことができるようになります。
この設定の場合、test-modeがオンのときは"TestMode"がモード行に表示されます。

<a href="http://tech.feedforce.jp/wp-content/uploads/2008/12/2008-12-09_1807.png" title="2008-12-09_1807.png"><img src="http://tech.feedforce.jp/wp-content/uploads/2008/12/2008-12-09_1807.png" alt="2008-12-09_1807.png" /></a>
<h3 align="justify">実際にマイナーモードを作ってみる</h3>
では、実際にマイナーモードを作成していきます。
ここでは<a href="http://www.rsssuite.jp" title="RSS Suite" target="_blank">RSS Suite</a>の管理画面で利用するファイル間を移動できるようにすることを目標とします。
<p align="justify">RSS Suiteの管理画面で必要となるファイルの構成は以下です。</p>

<ul>
	<li>lib/FormProcess/FormProcessXxxYyyZzz.php(フォーム処理)</li>
	<li>lib/PageContents/PageContentsXxxYyyZzz.php(コンテンツ表示)</li>
	<li>lib/qfd/xxx.yyy.zzz.qfd(フォームの定義)</li>
	<li>template/rss_admin/xxx.yyy.zzz.html(htmlテンプレート)</li>
</ul>
<p align="justify">命名規則からファイル名をうまく変換して、現在開いているファイルから対応するファイルへと移動できるようにします。</p>
 まず、Easy-Mmodeを利用して、RSS Suiteモードを定義します。
<pre><code> (easy-mmode-define-minor-mode rsssuite-mode
;; ドキュメント
 "This is RSS Suite Mode."
 ;; 初期値
 nil;; モード行への表示
 "RSSSuite"
 ;; マイナーモード用キーマップの初期値
 '(("C-cf" . suite-open-formprocess)
   ("C-cp" . suite-open-pagecontents)
   ("C-cq" . suite-open-qfd)
   ("C-ct" . suite-open-template)))</code></pre>
ここではそれぞれ4つの対応ファイルを開くためのキーマップを定義しています。
次に、切り替えるファイルへのパスをそれぞれ定義しておきます。
<pre><code> (defvar suite-qfd-path "lib/qfd/")
 (defvar suite-formprocess-path "lib/FormProcess/")
 (defvar suite-pagecontents-path "lib/PageContents/")
 (defvar suite-template-path "template/rss_admin/")
 (defvar suite-lib-path "lib/")</code></pre>
関数defvarで変数に値を定義しています。
次に関連ファイルを開いた時にrsssuite-modeをオンにするためhookを定義します。
この設定は必須ではありませんが、rss_suiteディレクトリ以下のファイルを開いた時に自動でrsssuite-modeがオンになる方がラクなのでそのようにします。
<pre><code>;; ファイルを開いた時のhook
(add-hook 'find-file-hooks
          (function (lambda ()
                      (suite-on-rsssuite-mode))))</code></pre>
find-file-hooksはファイルを訪問後に呼び出されます。

ここで実行しているsuite-on-rsssuite-mode関数は以下のように定義してあります。
<pre><code>;; RSS Suiteのディレクトリ配下であればrsssuite-modeにする
(defun suite-on-rsssuite-mode ()
  (if (string-match "rss_suite[^/]*/" default-directory)
      (unless rsssuite-mode (rsssuite-mode))))</code></pre>
変数rsssuite-modeはモードがオンになっていてばt, オフであればnilとなります。
関数rsssuite-modeはオン・オフを切り替える関数で、ここではオフの時のみオンにする処理にしています。

次に、マイナーモードのキーマップで定義した関数suite-open-formprocessを見ていきます。
<pre><code>;; 対応するFormProcessファイルを開く
(defun suite-open-formprocess ()
  (interactive)
  (setq suite-formprocess-file-path (concat (suite-get-top-dir)
                                            suite-formprocess-path
                                            "FormProcess"
                                            (suite-get-capitalized-name)
                                            ".php"))
  (set-window-buffer (selected-window) (find-file-noselect suite-formprocess-file-path))
  (suite-on-rsssuite-mode))</code></pre>
<p align="justify">defunで関数を定義しています。interactiveが含まれていると、 「M-x 関数名」で実行できるコマンドになります。
変数suite-formprocess-file-pathに、対応するFormProcessファイルの絶対パスを格納しています。
関数set-window-bufferは指定したウィンドウにバッファの内容を表示させます。ここでは選択されているウィンドウ(selected-windnow)に、確保したファイルsuite-formprocess-file-pathに対応するバッファを表示させています。

suite-formprocess-file-pathを求める部分では、関数concatで以下の文字列を連結しています。
<ul>
	<li>(suite-get-top-dir)</li>
	<li>suite-formprocess-path</li>
	<li>"FormProcess"</li>
	<li>(suite-get-capitalized-name)</li>
	<li>".php"</li>
</ul>
関数suite-get-top-dirの定義は以下です。
<pre><code> ;; RSS Suiteのトップディレクトリの絶対パスを取得
 (defun suite-get-top-dir ()
   (string-match "rss_suite[^/]*/" default-directory)
   (substring default-directory 0 (match-end 0)))</code></pre>
match-endには、string-matchの結果である終端のポイント位置が入ります。

関数suite-get-capitalized-nameの定義は以下です。
<pre><code> ;; キャメルケースのファイル名を取得
(defun suite-get-capitalized-name ()
  (cond
   ((suite-formprocessp) (string-match "FormProcess(.+).php" (suite-get-file-name)) (suite-get-main-name))
   ((suite-pagecontentsp) (string-match "PageContents(.+).php" (suite-get-file-name)) (suite-get-main-name))
   ((suite-qfdp)  (string-match "(.+).qfd" (suite-get-file-name)) (suite-dot-to-capitalize-string (suite-get-main-name)))
   ((suite-templatep) (string-match "(.+).html" (suite-get-file-name)) (suite-dot-to-capitalize-string (suite-get-main-name)))
   (t nil)))</code></pre>
現在開いているファイルがqfdファイル(xxx.yyy.zzz.qfd)やtemplateファイル(xxx.yyy.zzz.html)の場合、キャメルケースに変換して(XxxYyyZzz)返します。
変換しているのは、関数suite-dot-to-capitalize-stringの部分です。
<pre><code> ;; ファイル名からメインとなる部分の名前を切り出す
(defun suite-get-main-name ()
  (substring (suite-get-file-name) (match-beginning 1) (match-end 1))
  )</code></pre>
match-beginningやmatch-endには直前に評価しているstring-matchの結果が入ります。
<pre><code>;; ドットで連結されたファイル名をリストに変換
;; foo.bar.baz =&gt; (foo bar baz)
(defun suite-dot-to-capitalize-string (str)
  (suite-concat-capitalize-string-list (split-string str "."))
  )</code></pre>
split-stringはドットで区切ってリストにしています。
<pre><code>;; 文字列のリストをキャピタライズして連結する
;; (foo bar baz) -&gt; FooBarBaz
(defun suite-concat-capitalize-string-list (list)
  (cond
   ((= (length list) 1) (capitalize (car list)))
   (t (concat (capitalize (car list)) (suite-concat-capitalize-string-list (cdr list))))))</code></pre>
listの長さが1であれば、carでlistの先頭要素をキャピタライズして返します。
listの要素が2つ以上の場合は先頭要素をキャピタライズした文字列と、cdrで先頭要素を取り除いたlistを自身の関数suite-concat-capitalize-string-listに渡した結果の文字列と連結します。

逆に、ドットで区切られた名前から、キャピタライズした名前を取得する処理は以下です。
<pre><code>;; ドットで連結されたファイル名を取得
(defun suite-get-concatenated-name ()
  (cond
   ((suite-formprocessp) (string-match "FormProcess(.+).php" (suite-get-file-name)) (suite-split-capitalize-string (suite-get-main-name )))
   ((suite-pagecontentsp) (string-match "PageContents(.+).php" (suite-get-file-name)) (suite-split-capitalize-string (suite-get-main-name )))
   ((suite-qfdp) (string-match "(.+).qfd" (suite-get-file-name)) (suite-get-main-name))
   ((suite-templatep)  (string-match "(.+).html" (suite-get-file-name)) (suite-get-main-name))
   (t nil))
  )

;; キャメルケースの文字をドット区切りに分解
;; FooBarBaz -&gt; foo.bar.baz
(defun suite-split-capitalize-string (str)
  (setq case-fold-search nil)
  (string-match "^[A-Z][a-z]+" str)
  (cond
   ((= (match-end 0) (length str)) (downcase str))
   (t  (concat
	(concat (downcase (substring str (match-beginning 0) (match-end 0))) ".")
	(suite-split-capitalize-string (substring str (match-end 0) (length str)))
	))))</code></pre>
関数suite-split-capitalize-stringでは、受け取った文字列を先頭が大文字でそれ以降小文字が続く正規表現でマッチさせます。
もしstring-matchの結果の終端ポイント位置とstrの長さが同じであれば、downcaseして返します。
長さが異る場合は、downcaseした最初の単語に'.'を連結したものと、マッチ以降の文字を自身の関数suite-split-capitalize-stringに渡して返される文字列を連結します。

<p align="justify">以上で対応したファイル間を移動できるマイナーモードができました。
最後にソース全体を載せておきます。
<pre><code>
 ;; RSS Suite モード
(easy-mmode-define-minor-mode rsssuite-mode
                              ;; ドキュメント
                              "This is RSS Suite Mode."
                              ;; 初期値
                              nil
                              ;; on の時のモード行への表示
                              " RSSSuite"
                              ;; マイナーモード用キーマップの初期値
                              '(("C-cf" . suite-open-formprocess)
                                ("C-cp" . suite-open-pagecontents)
                                ("C-cq" . suite-open-qfd)
                                ("C-ct" . suite-open-template)
                                ))

;; Suiteのトップからそれぞれのファイルへのパス
(defvar suite-qfd-path "lib/qfd/")
(defvar suite-formprocess-path "lib/FormProcess/")
(defvar suite-pagecontents-path "lib/PageContents/")
(defvar suite-template-path "template/rss_admin/")
(defvar suite-lib-path "lib/")

;; ファイルを開いた時のhook
(add-hook 'find-file-hooks
          (function (lambda ()
                      (suite-on-rsssuite-mode))))

;; Suiteのディレクトリ配下であればRSSSuite modeにする
(defun suite-on-rsssuite-mode ()
  (if (string-match "rss_suite[^/]*/" default-directory)
      (unless rsssuite-mode (rsssuite-mode))))

;; suiteのトップディレクトリの絶対パスを取得
(defun suite-get-top-dir ()
  (string-match "rss_suite[^/]*/" default-directory)
  (substring default-directory 0 (match-end 0)))

;; 対応するFormProcessファイルを開く
(defun suite-open-formprocess ()
  (interactive)
  (setq suite-formprocess-file-path (concat (suite-get-top-dir)
                                            suite-formprocess-path
                                            "FormProcess"
                                            (suite-get-capitalized-name)
                                            ".php"))
  (set-window-buffer (selected-window)
		     (find-file-noselect suite-formprocess-file-path))
  (suite-on-rsssuite-mode))

;; 対応するPageContentsファイルを開く
(defun suite-open-pagecontents ()
  (interactive)
  (setq suite-pagecontents-file-path (concat (suite-get-top-dir)
                                             suite-pagecontents-path
                                             "PageContents"
                                             (suite-get-capitalized-name)
                                             ".php"))
  (set-window-buffer (selected-window)
		     (find-file-noselect suite-pagecontents-file-path))
  (suite-on-rsssuite-mode))

;; 対応するqfdファイルを開く
(defun suite-open-qfd ()
  (interactive)
  (setq suite-qfd-file-path (concat (suite-get-top-dir)
                                    suite-qfd-path
                                    (suite-get-concatenated-name)
                                    ".qfd"))
  (set-window-buffer (selected-window)
		     (find-file-noselect suite-qfd-file-path))
  (suite-on-rsssuite-mode))

;; 対応するテンプレートファイルを開く
(defun suite-open-template ()
  (interactive)
  (setq suite-template-file-path
	(concat (suite-get-top-dir)
		suite-template-path
		(suite-get-concatenated-name)
		".html"))
  (set-window-buffer (selected-window)
		     (find-file-noselect suite-template-file-path))
  (suite-on-rsssuite-mode))

;; ファイル名からメインとなる部分の名前を切り出す
(defun suite-get-main-name ()
  (substring (suite-get-file-name) (match-beginning 1) (match-end 1)))

;; キャメルケースのファイル名を取得
(defun suite-get-capitalized-name ()
  (cond
   ((suite-formprocessp)
    (string-match "FormProcess(.+).php" (suite-get-file-name))
    (suite-get-main-name ))
   ((suite-pagecontentsp)
    (string-match "PageContents(.+).php"
		  (suite-get-file-name)) (suite-get-main-name ))
   ((suite-qfdp)
    (string-match "(.+).qfd" (suite-get-file-name))
    (suite-dot-to-capitalize-string (suite-get-main-name )))
   ((suite-templatep)
    (string-match "(.+).html" (suite-get-file-name))
    (suite-dot-to-capitalize-string (suite-get-main-name )))
   (t nil)))

;; ドットで連結されたファイル名を取得
(defun suite-get-concatenated-name ()
  (cond
   ((suite-formprocessp)
    (string-match "FormProcess(.+).php" (suite-get-file-name))
    (suite-split-capitalize-string (suite-get-main-name )))
   ((suite-pagecontentsp)
    (string-match "PageContents(.+).php" (suite-get-file-name))
    (suite-split-capitalize-string (suite-get-main-name )))
   ((suite-qfdp)
    (string-match "(.+).qfd" (suite-get-file-name))
    (suite-get-main-name))
   ((suite-templatep)
    (string-match "(.+).html" (suite-get-file-name))
    (suite-get-main-name))
   (t nil)))

;; 文字列のリストをキャピタライズして連結する
;; (foo bar baz) -&gt; FooBarBaz
(defun suite-concat-capitalize-string-list (list)
  (cond
   ((= (length list) 1) (capitalize (car list)))
   (t (concat (capitalize (car list))
	      (suite-concat-capitalize-string-list (cdr list))))))

;; ドットで連結されたファイル名をリストに変換
;; foo.bar.baz =&gt; (foo bar baz)
(defun suite-dot-to-capitalize-string (str)
  (suite-concat-capitalize-string-list (split-string str "."))
  )

;; キャメルケースの文字をドット区切りに分解
;; FooBarBaz -&gt; foo.bar.baz
(defun suite-split-capitalize-string (str)
  (setq case-fold-search nil)
  (string-match "^[A-Z][a-z]+" str)
  (cond
   ((= (match-end 0) (length str)) (downcase str))
   (t  (concat
	(concat (downcase
		 (substring str (match-beginning 0) (match-end 0))) ".")
	(suite-split-capitalize-string (substring str
						  (match-end 0)
						  (length str)))))))

;; FormProcessかどうか
(defun suite-formprocessp ()
  (string-match "FormProcess" (suite-get-file-name)))

;; PageContentsかどうか
(defun suite-pagecontentsp ()
  (string-match "PageContents" (suite-get-file-name)))

;; qfdかどうか
(defun suite-qfdp ()
  (string-match ".*.qfd" (suite-get-file-name)))

;; テンプレートかどうか
(defun suite-templatep ()
  (string-match ".*.html" (suite-get-file-name)))

;; ファイル名取得
(defun suite-get-file-name ()
  (if buffer-file-name
      (file-name-nondirectory buffer-file-name)
    (error "there are not respond file")))</code></pre>