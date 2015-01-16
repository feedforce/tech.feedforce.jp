---
title: ブログをWordPressからMiddlemanに移行しました！
date: 2015-01-16 19:45 JST
authors: dkimura
tags: ruby, resume
---

お初にお目にかかります。鉛球を敵の眉間にブチ込むゲームが好きなdkimuraです。

先月末に当ブログを、[WordPress](https://wordpress.org/)から[Middleman](https://middlemanapp.com/)へ移行いたしました。
その際にハマった/悩んだところをご紹介させていただきます。

<!--more-->

## 移行の流れ

1. WordPressから、記事データをXMLでエクスポートする
1. **エクスポートした記事データをMarkdownに変換**
1. **middleman-blogコーディング**
1. Github Pagesでホスティング

今回は**太字**になっている箇所で苦労したお話をさせていただだきます。


## エクスポートした記事データをMarkdownに変換

既に記事移行用に、Rubyスクリプトが公開されていたのでForkして使用しました。
大半の記事は上手くMarkdownに変換できましたが、変換後の最終確認/調整は必要です。

> salmansqadeer/wordpress-to-middleman
> https://github.com/salmansqadeer/wordpress-to-middleman

> dkimura/wordpress-to-middleman
> https://github.com/dkimura/wordpress-to-middleman


### 変更したところ

- htmlからMarkdownへ変換してくれるgemを変更した
- 記事のファイル名と記事タイトル/ファイル名を別々にした


### 変換後、手動で修正したところ

- 埋め込みツイートが使われている記事
- WordPressのショートコード([caption]とか)が入っている記事
- 空見出し等、変な改行が入っている記事


## middleman-blogコーディング

### ハマり/悩みどころ

1. カテゴリの表示名とスラッグが別のものをどうするか
1. 検索機能どうするか

#### カテゴリ(タグ)の表示名とスラッグが別のものをどうするか

Middlemanは、WordPressと違ってスラッグ名/表示名の指定ができないため、
記事で指定した`tags`の内容を、表示名に変換する必要がありました。

上記の対応はカスタムヘルパーを作って対処しました。

##### helpers/custom.rb

```ruby
def slug_to_japanese(en_text)
  jp_text = ''

  data.category.each do |key, value|
    if en_text == key.en then
      jp_text = key.ja
    end
  end

  return jp_text
end
```

##### data/category.yml

```yaml
- en: "ruby"
  ja: "Ruby"
- en: "infrastructure"
  ja: "インフラ"
- en: "resume"
  ja: "勉強会資料"
- en: "operation"
  ja: "運用事例"
- en: "test"
  ja: "テスト"
- en: "dev_style"
  ja: "開発スタイル"
- en: "aws"
  ja: "AWS"

# en: スラッグ
# ja: 表示名
```

##### ERBでのコード例

```erb
<% blog.tags.each do |tag, articles| %>
  <li><%= link_to "#{slug_to_japanese(tag)}", tag_path(tag) %></li>
<% end %>
```

#### 検索機能どうするか

Middlemanは静的サイトであるため、サイト内検索機能がありません。

現在は、[Googleのカスタム検索](https://www.google.co.jp/cse/compare)で補ってますが、
検索ボックスのデザインが変わってしまっているので何とかしたい気持ちが…。

代替措置は結構選択肢がありますので、そのうち試したいと思っています。

- [Middleman+GitHub で構築したサイトの検索画面を作る](http://ja.ngs.io/2015/01/02/middleman-blog-search/)
- [Middlemanでブログの検索機能を実装する！](http://gold-experience.jp/articles/2014/02/16/middleman_blog_search.html)
- [Swiftype](https://swiftype.com/)


## まとめ

- 移行作業の大半は、XMLとの戦いだった
- **静的サイト**なので動的サイトである故に出来てたことはできなくなるから考慮しようね
