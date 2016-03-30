---
title: 今から始めるRubyエンジニアのためのElixir Phoenix part1
date: 2016-03-30 13:00 JST
authors: tsub
tags: elixir
---

こんにちは!2016卒エンジニア内定者のtsubです
なかなか社内での呼び名が安定しなくて困っています。つらい
ちなみに自分が使っている名前のtsubは __tsub(ティーサブ)__ と呼ぶらしい。\最近知った!/

さて、もうすぐ4月になりますが、この時期になると
（´-`）.｡oO(なんか春だしいつもと違う言語とか手を出してみようかな...)
とか思っちゃいますよね！

ということで、満を持して以前から気になっていたElixirとPhoenixを学んでみようと思います（PhoenixはElixirで実装されたウェブアプリケーションフレームワークです）。

第1回目の今回は、Elixirの基本的な構文や制御文について触れていきます。

<!--more-->

## この記事の対象読者
- RailsエンジニアだけどPhoenixなにそれカッコイイじゃんな人
- Railsとか書いたことないけどこの機会にPhoenixでweb書いてみたい人
- Elixir、Phoenixに興味がある人

## この記事の目的
- Elixirの基本的な構文を理解して簡単なプログラムが書けるようになる

## Elixir環境構築

### インストール

macの場合はbrewを使って簡単に構築できます

```
$ brew update
$ brew install elixir
```

それ以外の環境の方は以下の公式サイトを参考にしてください

- [Installing Elixir - Elixir](http://elixir-lang.org/install.html)

### REPLの起動・終了

ファイルにコードを書いて実行してもいいですが、ElixirはREPL(Read Eval Print Loop)を提供していますのでそれを使って学んでいきます

`iex`で起動できます

```
$ iex
Erlang/OTP 18 [erts-7.2.1] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Interactive Elixir (1.2.3) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

終了するときは`Ctrl-C`です

```
iex(1)>
BREAK: (a)bort (c)ontinue (p)roc info (i)nfo (l)oaded
       (v)ersion (k)ill (D)b-tables (d)istribution
a↩︎
```

## Elixirの構文を学ぶ(簡単に)
ElixirはRubyによく似た構文を持っているため、Rubyエンジニアは親しみを持ちやすいのではないでしょうか

例えば、以下のコードを比較すると、

__Elixir__

```
defmodule FizzBuzz do
  def call(x) do
    cond do
      rem(x, 15) == 0 -> "FizzBuzz"
      rem(x, 3) == 0 -> "Fizz"
      rem(x, 5) == 0 -> "Buzz"
      true -> x
    end
  end
end

1..30 |> Enum.map(fn i -> IO.inspect FizzBuzz.call(i) end)
```

__Ruby__

```
class Fixnum
  def fizzbuzz
    return "FizzBuzz" if self % 15 == 0
    return "Fizz" if self % 3 == 0
    return "Buzz" if self % 5 == 0
    return self
  end
end

(1..100).map { |i| i.fizzbuzz }.each { |i| puts i }
```

関数型言語とオブジェクト指向言語という大きな違いはあるもののなんとなく似ているような気がします。

今回はRubyとの比較用のコードですが、もちろんこれがElixirっぽい書き方かと言われるとそうではありません。
パターンマッチやマクロといった機能を使うのがElixirっぽいコードとしてはベターかと思われます。

今回はそこまで深く説明しませんが、興味がある方はこちらを参考にしてみてください

- [Pattern matching - Elixir](http://elixir-lang.org/getting-started/pattern-matching.html)
- [Macros - Elixir](http://elixir-lang.org/getting-started/meta/macros.html)

ちなみに`class Fixnum`のようにRubyではモンキーパッチが使えますが、Elixirはコンパイラ型言語のためオープンクラスのような概念はありません。

### 基本的な型
さて、まずは基本的な型について学んでいきます。

公式のドキュメントを参考に進めていきます。

- [Basic types - Elixir](http://elixir-lang.org/getting-started/basic-types.html)

よく使うものはこのあたりになるかと思います

```
iex> 1              # integer
iex> 1.0            # float
iex> true           # boolean
iex> :atom          # atom / symbol
iex> "elixir"       # string
iex> [1, 2, 3]      # list
iex> [hoge: "fuga"] # list
iex> {1, 2, 3}      # tuple
```

ほとんどRubyに近いですね。

それぞれの型について細かく見ていきましょう。

#### 整数、小数 Integer, Float
整数や浮動小数の扱いは基本的にはRubyと変わりません

```
iex> 1 + 2 # => 3
iex> 5 * 5 # => 25
iex> 10 / 2 # => 5.0
iex> 1.0 + 2 # => 3.0
iex> Float.ceil(1.6) # => 2.0
iex> Float.floor(1.6) # => 1.0
```

`10 / 2`が`5.0`になる点だけ注意が必要です。
Elixirにおける`/`演算子は常に浮動小数を返します。

もし整数が必要なら`div()`を使います。

```
iex> div(10, 2) # => 5
iex> is_integer(10 / 2) # => false
iex> is_integer(div(10, 2)) # => true
```

#### 真偽値 Boolean
Elixirの真偽値はRubyと同じで、`false`, `nil`のみfalseとして扱い、それ以外は全てtrueになります。

```
iex> if "hoge"
...>   "fuga"
...> end
"fuga"
iex> if nil
...>   "fuga"
...> end
nil
```

#### アトム Atom / Symbol
`:atom`はRubyのSymbolに近いですが、ElixirではAtomとも呼びます
Atomと呼ぶ方が主流みたいです

ちなみにBooleanのtrue, falseもAtomで定義されています

```
iex> true == :true # => true
iex> false == :false # => true
```

#### 文字列 String
Rubyと同様に変数の文字列展開が可能です

```
iex> hoge = "world"
iex> "Hello, #{hoge}!" # => "Hello, world!"
```

その他各種関数が提供されています

```
iex> String.length("hoge") # => 4
iex> String.upcase("hoge") # => "HOGE"
```

#### 配列 List
Listにはどんな型の値も入れることができます

```
iex> ["hoge", 1, :foo, true, ["fuga"]]
```

Listの連結や差し引きもできます

```
iex> [1, 2] ++ [3, 4] # => [1, 2, 3, 4]
iex> [1, 2, 3, 4] -- [3, 4] # => [1, 2]
```

連想配列もできます

```
iex> list = [hoge: "fuga", foo: "bar"]
iex> list[:hoge] # => "fuga"
```

#### タプル Tuple
TupleはRubyにはないので少しわかりづらいかもしれません。
Listに似ているようですが役割が違います。

まず、Listと挙動を比較してみます。

```
iex> list = ["hoge", "fuga"]
iex> tuple = {"hoge", "fuga"}

# 値の取得
iex> Enum.at(list, 0) # => "hoge"
iex> elem(tuple, 0) # => "hoge"

# 値の追加
iex> List.insert_at(list, -1, "foo") # => ["hoge", "fuga", "foo"]
iex> Tuple.append(tuple, "foo") # => {"hoge", "fuga", "foo"}

# 値の削除
iex> List.delete_at(list, 1) # => ["hoge"]
iex> Tuple.delete_at(tuple, 1) # => {"hoge"}

# 追加・削除した時は新たなList, Tupleを返すため、元の変数の値は変わらない
iex> list # => ["hoge", "fuga"]
iex> tuple # => {"hoge", "fuga"}
```

このように、全く別々の関数が提供されているため、扱いに注意しなければいけません。

また大きな違いとして、Listは各要素に次の要素のメモリ番地が入っていますが、Tupleの場合は連続した番地に入るように確保されます。

例えばそれぞれの長さを知りたい場合、Listだと最初の要素から最後まで順番にアクセスしていかなければならないため遅いです。
しかし、Tupleだと最初から一定の長さでメモリを確保しているため、長さを知るのは速いです。

```
iex> length(list) # 遅い
iex> tuple_size(tuple) # 速い
```

同様にListだと指定したインデックスの値を参照するには最初から辿っていく必要があるので遅いですが、Tupleだと速いです。

```
iex> Enum.at(list, 1) # 遅い
iex> elem(tuple, 1) # 速い
```

一方で、値の追加や削除をする場合はListだと1つの番地を確保して、参照先を変更するだけで済むため速いです。
しかし、Tupleは新しく連続した番地を確保しなければいけないため遅いです。

```
iex> List.insert_at(list, -1, "foo") # 速い
iex> Tuple.append(tuple, "foo") # 遅い
```

### 制御構文
次に、Elixirの基本的な制御構文について見ていきます。

制御構文についても、公式ドキュメントを参考に進めていきます

- [case, cond and if - Elixir](http://elixir-lang.org/getting-started/case-cond-and-if.html)

#### if, unless
if文、unless文はRubyと違い、`do`が必要です

```
iex> if true do
...>   "This works!"
...> end
"This works!"
iex> unless true do
...>   "This works!"
...> end
nil
```

もちろんelseも使えます

```
iex> if false do
iex>   "This won't be seen"
iex> else
iex>   "This will"
iex> end
```

ただし、elsifはありませんので後述のcondを使いましょう

#### case
case文は以下のように書きます。

```
iex> x = 10
iex> case x do
...>   1  -> "Won't match"
...>   10 -> "Will match"
...>   _  -> "Won't match"
...> end
"Will match"
```

ちなみにElixirでは以下のように書くこともできます。

```
iex> x = {1, 2, 3}
iex> case x do
...>   {1, x, 3} when x > 0 ->
...>     "Will match"
...>   _ ->
...>     "Won't match"
...> end
"Will match"
```

ただし、このような書き方はパターンマッチの概念を理解する必要がありますので今回は割愛させていただきます。

#### cond
caseは最初に定義した１つの値が複数の値と比較してマッチするかで分岐していましたが、condは複数の条件式を比較してtrueになったかで分岐するという用途に使います。

例えば以下のように書きます。

```
iex> cond do
...>   2 + 2 == 5 ->
...>     "This will not be true"
...>   2 * 2 == 3 ->
...>     "Nor this"
...>   1 + 1 == 2 ->
...>     "But this will"
...> end
"But this will"
```

この中だと`1 + 1 == 2`の条件式がtrueになるのでBut this willが出力されます

#### Recursion
Elixirではfor文がなく、代わりに再帰でループ処理を表現します。

例えば、Rubyでは以下のようにループを書きます

```
(0...3).each do
  p 'Hello!'
end
```

一方、Elixirはこのように書きます。

```
defmodule Recursion do
  def print_multiple_times(msg, n) when n <= 1 do
    IO.puts msg
  end

  def print_multiple_times(msg, n) do
    IO.puts msg
    print_multiple_times(msg, n - 1)
  end
end

Recursion.print_multiple_times("Hello!", 3)
```

このように、ループを表現する際には再帰的な関数を用意します。

ちなみに、`print_multiple_times(msg, n)`が2つ定義されてますが、Elixirではこのように複数の同名関数を定義し、条件によって呼び出すものを変えることができます。

しかしながら、これもパターンマッチの一種となりますので本記事では詳しく扱いません。

## まとめ
今回はRubyと比較をしながら、Elixirの導入方法や、基本的な構文、制御文について学びました。

次回はPhoenixについて学んでいきたいと思います。
