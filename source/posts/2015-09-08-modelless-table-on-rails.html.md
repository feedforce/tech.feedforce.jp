---
title: Rails で動的にテーブルを作成して、大きな CSV のデータをインポートする方法
date: 2015-09-08 20:52 JST
authors: e-takano
tags: rails
---

こんにちは！ SQL 大好き kano-e です。

「データ更新のたびに新規にテーブルを作って、そこにデータを投入したい」とか。
「お客様毎にテーブルを分けたいが、お客様情報は DB に保存されていて、増減するので migration で作っておくことができない」とか。
以外と遭遇率が高い状況です。

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

### テーブルの作成: create_table

Rails だと、動的にテーブルを作るのは簡単で

```
ActiveRecord::Base.connection.create_table(table_name) do |t|
  t.string :code   t.string :name
end
```

のように書けば、テーブルを作れてしまいます。

見ての通り、この書き方はいつもの migration と同じです。

例えば

* Product というモデルがあって
* name というユニークな attributes を持っている時に
* Product インスタンス毎にテーブルを作成したい

という場合、以下のように書きます。

```
class Product < ActiveRecord::Base
  def create_temporary_table
    ActiveRecord::Base.connection.create_table("temporary_#{name}") do |t|
      t.string :title
      t.string :description
    end
  end
end
```

これで `Production#create_temporary_table` を呼ぶと `CREATE TABLE` が発行されて、新しいテーブルが作成されます。

### テーブルの存在確認: table_exists?

作成済みかどうかを判断したい場合は `#table_exists?` が使えます。

```
ActiveRecord::Base.cnnection.table_exists?(table_name)
```

テーブルが存在しなかった場合のみ新規作成する、といったことができるようになりました。

### テーブルの削除: drop_table

テーブルの削除は、もうお分かりかと思いますが `#drop_table` が使えます。

```
ActiveRecord::Base.connection.drop_table(table_name)
```

ここまでで「古いテーブルが存在した場合は削除してから、新しいテーブルを作成する」にも対応可能です。

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

モデルを作りたくなる気持ちを無視して、まずはカラムの情報を取得します。

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

PostgreSQL には CSV のデータをテーブルに投入するための方法が、いくつか用意されています。

例えば、PostgreSQL が動いているサーバ上に CSV が配置できるのであれば COPY にファイルパスを渡すことで、データ投入が可能です。
残念ながら、この方法は RDS の場合にはできません。

メタコマンドの `\copy` であればリモートの CSV も渡せるのですが、その場合 pg gem ではメタコマンドを使用できませんので、 pg を経由せずに直接 psql を操作しないといけません。

`COPY` に標準入力を渡す SQL を書くことも可能です。
例えば対象の CSV を元に以下のような SQL ファイルを作って

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

ただし、この場合も `\copy` と同じく、直接 psql コマンドを操作する必要があります。

Rails プロセスから、手軽に COPY を使いたい場合は [postgres-copy](https://github.com/diogob/postgres-copy) という gem を使うのが良さそうです。

pg gem にはもともと COPY を実行するメソッドがあり、 postgres-copy はそれを柔軟に扱えるようにラッピングしてくれています。

```
ModelName.copy_from '/path/to/copy.csv', tabel: table_name, columns: [column1, column2, column3]
```

詳細な使い方はこの記事では省きますが、モデルのテーブルにデータ投入するだけであれば、`copy_from` にCSVのパスだけ渡せば使えます。
今回のケースでは動的にテーブルが作成されているため table や columns などのオプションを渡しています。

postgres-copy を使う利点としては、

* CSV 以外にも、複数のフォーマットのデータを扱える
* テーブルスキーマと CSV データのマッピングを手軽に行える
* CSV の内容に手を加えた上で投入できるようになっている

辺りでしょうか。

ただし postgres-copy が CSV の毎行処理を行っている分、(多少ではありますが) CPU 負荷もかかります。

* ファイルのフォーマットがある程度決まっていて
* 手を加える必要なくデータ投入できる

ようなケースでは、直接 pg の copy_data を使っても手間はさほど変わりません。

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

pg の connection を使った場合でも、 `\copy` と比べて CPU 負荷はかかりますが、実行時間に違いは見られませんでした。

Rails プロセス内から実行するのであれば、扱いやすさを考えて copy_data を使い、投入したいデータによっては postgres-copy で楽をする、というのが良さそうです。

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
