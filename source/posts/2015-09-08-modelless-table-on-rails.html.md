---
title: Rails で動的にテーブルを作成して、大きな CSV のデータをインポートする方法
date: 2015-09-08 20:52 JST
authors: e-takano
tags: rails
---

こんにちは！ SQL 大好き kano-e です。

「データ更新のたびに新規にテーブルを作って、そこにデータを投入したい」とか。
「お客様毎にテーブルを分けたいが、お客様情報は DB に保存されていて、増減するので migration で作っておくことができない」とか。
意外と遭遇率が高い状況です。

この記事では、そんな時に多分役立つ「Railsで動的にテーブルを作成して、大きな CSV のデータをインポートする方法」について、思いつくままにまとめてみました。
合わせて読みたい「動的に作成したテーブルを db/schema.rb に含めない方法」のおまけ付きです。


<!--more-->

## はじめに

この記事では、以下の内容について書いています。

* Rails で動的にテーブルを CREATE/DROP する
* テーブルに対応するモデルを用意せずに SQL を組み立て/発行する
* サイズの大きい CSV のデータを DB (PostgreSQL) に投入する

動作確認環境は、以下になります。

* Ruby 2.2.3
* Rails 4.2.4
* PostgreSQL 9.4.0

## 動的にテーブルを作成したり削除したりしたい

Rails だと、動的にテーブルを作るのは簡単で

```
ActiveRecord::Base.connection.create_table(table_name) do |t|
  t.string :code   t.string :name
end
```

のように書けば、テーブルを作れてしまいます。
見ての通り、この書き方はいつもの migration と同じです。

動的にテーブル生成をしていると、テーブルが作成済みかどうかを判断したくなる時があります。
その場合は `#table_exists?` が使えます。

```
ActiveRecord::Base.cnnection.table_exists?(table_name)
```

テーブルの削除は、もうお分かりかと思いますが `#drop_table` です。

```
ActiveRecord::Base.connection.drop_table(table_name)
```

例えば

* Product というモデルがあって
* name というユニークな attributes を持っている時に
* Product インスタンス毎にテーブルを作成したい
* すでにテーブルが存在している時はテーブル作成前に古いテーブルを削除しておきたい

という場合、以下のように書けます。

```
class Product < ActiveRecord::Base
  def create_temporary_table
    connection = ActiveRecord::Base.connection
    table_name = "temporary_#{name}"
    connection.drop_table(table_name) if connection.table_exists?(table_name)
    ActiveRecord::Base.connection.create_table(table_name) do |t|
      t.string :title
      t.string :description
    end
  end
end
```

## 動的に作成したテーブルの操作

### 対応するモデルを作成する

動的に作成したテーブルを操作するために一番簡単な方法は、対応するモデルを作ることかと思います。

その場合、テーブルが動的なのでモデルも動的に生成する必要があります。

```
klass = Class.new(ActiveRecord::Base) do |c|
  c.table_name = table_name
end
Object.const_set(model_name, klass)
```

何度も `Class.new` するのは効率が悪いので、あらかじめ `Object.const_get(model_name)` で確認し、何度も同じクラスを作らないようにした方が良いです。
でないと、無駄に Class インスタンスが生成され続けてしまいます。

動的にカラムが変わる可能性がある場合には、Class インスタンスを使いまわしているとスキーマに追随できなくなってしまうため、テーブルを作り直すなどのタイミングで `klass.reset_column_information` を呼ぶ必要があります。

### モデルを作らずに SQL を実行する

モデルを作らずに `ActiveRecord::Base.connection.execute` で頑張ることも可能です。

SQL 組み立て時に、埋め込む値を適宜クオートするために `#quote_table_name` と `#quote_column_name` が使えます。
(クオートしなくても動くことは多いですが、クオートする方が安心ですよね)

```
ActiveRecord::Base.connection.quote_table_name('table_name')
ActiveRecord::Base.connection.quote_column_name('column_name')
```

これで、それぞれテーブル名とカラム名が、使っている RDB に応じてクオートされます。

カラムに入れる値のクオートは、カラムの型情報などが必要になるため、一手間だけ余分に必要です。

モデルが存在する場合は `ModelClass.column_for_attribute(column_name)` で取得できるのですが、なにせ今回はモデルを作っていません。

モデルを作りたいような気持ちが湧き上がってきますが、それには気付かない振りをして、まずはカラムの情報を取得します。

```
ActiveRecord::Base.connection.columns(table_name)
```

これでカラム情報が Array で返ってきます。
Array の中から値を投入するカラムを見付け、それをクオートしたい値とともに `#quote` に渡します。

```
columns = ActiveRecord::Base.connection.columns(table_name)
column = columns.find{|c| c.name == column_name }
ActiveRecord::Base.connection.quote(value, column)
```

それらを利用して SQL を組み立て `ActiveRecord::Base.connection.execute` に渡せば SQL の結果が返ってきます。

```
connection = ActiveRecord::Base.connection

count_sql = "SELECT COUNT(*) AS #{connection.quote_column_name('count')} FROM #{connection.quote_table_name(table_name)}"
count_result = connection.execute(count_sql)
count_result.first #=> {"count" => 0}

column = connection.columns(table_name).find{|c| c.name == column_name }
update_sql = <<"SQL"
UPDATE #{connection.quote_table_name(table_name)}
  SET #{connectionn.quote_column_name(column_name)} = #{connection.quote(str, column)}
  WHERE #{connectionn.quote_column_name(column_name)} IS NULL
SQL
update_result = connection.execute(update_sql)
update_result.cmd_status #=> "UPDATE 2"
update_result.cmd_tuples #=> 2
```

## 行数の多い CSV のデータを DB に投入したい

### COPY 〜 FROM 〜 WITH csv

PostgreSQL の COPY コマンドは CSV のパスや標準入力などを受け取って、指定のテーブルにデータをコピーします。

ただし COPY コマンドはサーバ上で実行されるので、サーバ上からアクセス可能な場所に CSV を置かないといけません。
そのため、例えば AWS を使っていて EC2 にある CSV ファイルの中身を RDS に投入したい、という時には使えません。

標準入力を渡す場合は EC2 の `psql` 経由で、データの投入が可能です。
CSV を元に以下のような SQL ファイルを用意して、

```
COPY table_name (column1, column2, column3) FROM stdin WITH csv;
data1,data2,data3
...
\.
```

これを psql に渡します。

```
$ psql -U username -h host --dbname database --file=/path/to/copy.sql
```

### \copy

メタコマンド `\copy` も COPY コマンドのように、 CSV のパスや標準入力からデータをコピーします。

`\copy` に CSV のパスを渡した場合、 psql がファイルの読み書きを実行してサーバに送信するので、例えば AWS を使っていて EC2 にある CSV ファイルの中身を RDS に投入したい、という時にも使えます。

```
\copy table_name (column1, column2, column3) from '/path/to/copy.sql' with csv;
```

### Rails から実行する

pg gem ではメタコマンドが扱えないため、 Rails からは `\copy` を手軽に扱うことはできません。
どうしても実行したい場合は、 Rails から `psql` コマンドを実行するようなことをする必要があります。

COPY コマンドの方は pg gem に COPY を実行する `#copy_data`, `#put_copy_data` というメソッドがあります。
Rails からであれば、

```
connection = ActiveRecord::Base.connection
io = File.open('/path/to/copy.csv')
connection.raw_connection.copy_data 'COPY table_name (column1, column2, column3) FROM stdin WITH csv' do
  while line = io.gets do
    connection.raw_connectioon.put_copy_data line
  end
end
io.close
```

これで実行できます。

[postgres-copy](https://github.com/diogob/postgres-copy) という `#copy_data` を手軽に扱える gem もあります。
実は pg gem の `#copy_data` の使い方は、この gem のコードを読んで ~~パクリ~~ 勉強しました。

postgres-copy の詳細な使い方はこの記事では省きますが、モデルのテーブルにデータ投入するだけであれば `ModelName.copy_from '/path/to/copy.csv'` だけでできるようになります。
今回はモデルを持たないテーブルが対象ですが、その場合も

```
ModelName.copy_from '/path/to/copy.csv', tabel: table_name, columns: [column1, column2, column3]
```

のように table_name や columns をオプションで渡すことができます。

postgres-copy を使う利点としては、

* CSV 以外にも、複数のフォーマットのデータを扱える
* テーブルスキーマと CSV データのマッピングを手軽に行える
* CSV の内容に手を加えた上で実行できるようになっている

辺りでしょうか。

逆に、

* CSV ファイルのフォーマットがある程度決まっていて
* 手を加える必要なくデータ投入できる

ようなケースでは、直接 pg の `#copy_data` を使っても良いかと思います。
多少ながら、いくつかの処理を省ける分 postgres-copy を使うよりも CPU 負荷を少なくすることができます。

## おまけ: 動的に作ったテーブルが db/schema.rb に含まれて面倒

開発環境で動的なテーブル生成を試していると db/schema.rb に無駄な差分ができてしまい、面倒で悲しい気分になることがあります。
それがうっかりコミットされてしまうと、ほかのメンバーまで不幸になってしまいます。

そういう時は `ActiveRecord::SchemaDumper.ignore_tables` を設定することで、特定のテーブルを schema に含まないようにできます。

複数指定可、正規表現での指定可なので、動的にテーブル名が変わるような場合でも、 prefix や suffix を決めておくことで、以下のように指定できます。

```
# config/environments/development.rb

Rails.application.configure do
  # (略)

  ActiveRecord::SchemaDumper.ignore_tables = [
    /\Aprefix_[a-z0-9][_a-z0-9]+\z/,
    /\A[a-z0-9]+_suffix\z/,
  ]
end
```

これで、無駄な差分に煩わされなくなりました。
