---
title: The Atom Syndication Format
date: 2006-10-20 15:12 JST
authors: yanagi
tags: resume,
---
RSS の代替を目指した新しいフォーマット

2003年6月 IBM の Sam Ruby が仕様策定のための行動を開始

Atom は仕様群の総称

- The Atom Syndication Format (コンテンツ配信のためのフィードフォーマット)
- The Atom Publishing Protocol (コンテンツ編集のためのプロトコル)
- Atom Feed Autodiscovery (フィードを自動的に見つけるための記述)

<!--more-->  

## Atom 配信フォーマットとは

RSS の代替を目指した新しいフォーマット

2003年6月 IBM の Sam Ruby が仕様策定のための行動を開始

Atom は仕様群の総称

- The Atom Syndication Format (コンテンツ配信のためのフィードフォーマット)
- The Atom Publishing Protocol (コンテンツ編集のためのプロトコル)
- Atom Feed Autodiscovery (フィードを自動的に見つけるための記述)

Atom の目指すもの

- 特定のベンダに依存しない
- 全ての人が自由に実装できる
- 誰でも自由に拡張できる
- 明確かつ完全に仕様が決められている

IETF によって仕様が管理されている

- RFC4287 [http://www.ietf.org/rfc/rfc4287](http://www.ietf.org/rfc/rfc4287)

## Atom コンストラクト

Atom フォーマット内で使われる共通のデータ構造

### Text コンストラクト

type 属性が "text" "html" "xhtml" のいずれか

#### Text

- 子要素を含んではいけない。

```html
<title type="text">
  Less: &lt;
</title>
```

#### HTML

- 子要素を含んではいけない。
- マークアップは全てエスケープしなければならない。
- HTML の <div> の中に直接現れる形にすべき

```html
<title type="html">
  Less: &lt;em> &amp;lt; &lt;/em>
</title>

```

#### XHTML

- 1 つ の XHTML div 要素でなければならない。
- div 要素そのものをコンテンツの一部とみなしてはならない。

```html
<title type="xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml">
  <xhtml:div>
    Less: <xhtml:em> &lt; </xhtml:em>
 </xhtml:div>
</title>
```

### Person コンストラクト

Person コンストラクト内には、1 個の atom:name 要素と 0 個または 1 個の atom:uri 要素、atom:email 要素を含む。

#### atom:name 要素

人物の名前。人間が読める形式。

#### atom:uri 要素

人物に関連付けられた IRI。

#### atom:email 要素

人物に関連付けられたメールアドレス。

### Date コンストラクト

RFC3339 の date-time 形式

```xml
<updated>2003-12-13T18:30:02Z</updated>
<updated>2003-12-13T18:30:02.25Z</updated>
<updated>2003-12-13T18:30:02+01:00</updated>
<updated>2003-12-13T18:30:02.25+01:00</updated>
```

## Atom フィードの構造

### atom:feed 要素内の必須要素

ルートは atom:feed 要素。feed 要素内には次の要素が必須。

- atom:id
- atom:title
- atom:updated

#### atom:id 要素

フィードの一意な識別子。IRI でなくてはならない。 Atom フィードが移転・再発行などされたとしても、atom:id 要素を変えてはいけない。

#### atom:title 要素

フィードのタイトル。

Text コンストラクト。

#### atom:updated 要素

フィードに関して、配信者が重要だと考える更新が行われた日時。 フィードが修正されたからと言って、必ずこの要素を更新しなければならないわけではない。

Date コンストラクト。

### atom:feed 要素内の任意要素

#### atom:author 要素

著者を表わす。

Person コンストラクト。

atom:feed 要素は 1 個以上の atom:feed 要素を含まなければならないが 全ての atom:entry 要素が atom:author 要素を含んでいれば、省略できる。

#### atom:category 要素

カテゴリ情報

#### atom:contributor 要素

貢献者。

Person コンストラクト。

#### atom:generator 要素

フィード生成に行なわれたエージェント。

uri 要素と version 要素を子要素に持てる。

#### atom:icon 要素

フィードのアイコン画像の IRI。

#### atom:link 要素

#### atom:logo 要素

フィードのロゴ画像の IRI。

#### atom:rights 要素

フィードの権利情報。

Text コンストラクト。

#### atom:subtitle 要素

サブタイトル。

Text コンストラクト。

#### atom:entry 要素

個々のエントリ。 後述

### atom:entry 要素内の必須要素

- atom:id 要素
- atom:title 要素
- atom:updated 要素

### atom:entry 要素内の任意要素

#### atom:author 要素

#### atom:category 要素

#### atom:content 要素

エントリのコンテンツまたはコンテンツへのリンクを表わす要素。

#### atom:contributor 要素

#### atom:link 要素

#### atom:published 要素

エントリが生まれるイベントに関連付けられた日時。

Date コンストラクト。

#### atom:rights 要素

#### atom:source 要素

atom:entry が他のフィードから複製されたとき、 その元となる atom:feed 要素のメタデータを格納する。

#### atom:summary 要素

要約情報。

Text コンストラクト。

## References

- [http://www.ietf.org/rfc/rfc4287](http://www.ietf.org/rfc/rfc4287)
- [http://www.futomi.com/lecture/japanese/rfc4287.html](http://www.futomi.com/lecture/japanese/rfc4287.html)
- [http://www.mdn.co.jp/index.php?option=com\_content&task=view&id=752&Itemid=54](http://www.mdn.co.jp/index.php?option=com_content&task=view&id=752&Itemid=54)

