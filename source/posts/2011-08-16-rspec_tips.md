---
title: RSpecの話を少し
date: 2011-08-16 17:22 JST
authors: r-suzuki
tags: ruby, test, resume, 
---

弊社内のRubyを使ったプロジェクトでは、自動テストツールのひとつとしてRSpec(バージョン2と1両方)を使っています。
 先日社内勉強会でRSpecのトピックを取り上げたので、いくつか紹介したいと思います。

 <!--more-->

## Tipsなど
 (以下のコードはバージョン1でも動作します) 
### as\_null\_object

通常、Mockオブジェクトに対してstub定義していないメソッドを呼ぶとMockExpectationErrorが発生します。ですがテストによっては、ある特定のメソッド呼び出し以外を無視したいケースもあるでしょう。（例えばログ出力内容の検証など）  
 その場合はMockオブジェクトに対してas\_null\_objectメソッドを呼んでおくことで、特定のメソッド呼び出し以外を無視することができます。

```ruby
def start(logger)
  logger.debug('debug message.')  # as_null_objectによりinfo呼び出し以外は無視される
  logger.info('start')
  # ...
end

it '処理開始がログに記録されること' do
  logger = mock('logger').as_null_object
  logger.should_receive(:info).with('start')
  start(logger)
end</code>
</pre>
```

#### 参考

- [Null Objectパターン](http://en.wikipedia.org/wiki/Null_Object_pattern)
- [Method: Spec::Mocks::Methods#as\_null\_object](http://rdoc.info/gems/rspec/1.3.2/Spec/Mocks/Methods:as_null_object)

### Shared Examples

例えばダックタイピングを適用して、同じように振る舞うクラスを複数実装したとしましょう。その共通する振る舞いのテストコードを別々に用意すると、重複が発生してしまいますし保守が面倒です。  
 RSpecではそういった共通するexample群に名前を付けて、example group間で共有することができます。

```ruby
shared_examples_for &quot;Feedforce社員&quot; do
  it &quot;なぜか社長の誕生日を覚えていること&quot; do
    should ...
  end
end

describe 'エンジニア' do
  subject { Engineer.new }
  it_should_behave_like 'Feedforce社員'
end

describe 'ディレクタ' do
  subject { Director.new }
  it_should_behave_like 'Feedforce社員'
end
```

#### 参考

- [Method: Spec::DSL::Main#share\_examples\_for](http://rdoc.info/gems/rspec/1.3.2/Spec/DSL/Main:share_examples_for)

### マッチャいろいろ

「should ==」ばかり使ってテストを書くこともできますが、適したマッチャを使うことでテストの内容がより明確になり、分かりやすい失敗メッセージを得ることができます。

#### have(n)

```ruby
columns = [1, 2, 3]

# これでも悪くはないですが...
columns.size.should == 4      # &quot;expected: 4, got: 3 (using ==)&quot;

# こちらの方が良い
columns.should have(4).items  # &quot;expected 4 items, got 3&quot;
```

#### be(\*args)

```ruby
result = 11

# これでも間違いではないですが...
(result &lt; 10).should be_true  # &quot;expected false to be true&quot;

# こちらの方が良い
result.should be &lt; 10         # &quot;expected &lt; 10, got 11&quot;
```

ちなみにbeの実装はMatchers::Beのインスタンスを返してMatchers::Beは演算子"<"の実装をオーバーライドしてるからMatchers::BeComparedToのインスタンスを返して、それがshouldの引数になって...という具合です。

### Stub chain

stub\_chainメソッドを使うことで、あるオブジェクトの関連オブジェクトのさらに関連オブジェクト...のようにネストしたスタブを一度に定義できます。  
 あまりにネストした関連は設計を改善した方が良さそうですが...。

```ruby
# こう書いても良いが...
boss = mock('ボス', :policy =&gt; 'みんながんばれ')
member.stub!(:boss).and_return(boss)
member.boss.policy  # 'みんながんばれ'

# こう書ける
member.stub_chain(:boss, :policy).and_return('みんながんばれ')
member.boss.policy  # 'みんながんばれ'
```

#### 参考

- [Method: Spec::Mocks::Methods#stub\_chain](http://rdoc.info/gems/rspec/1.3.2/Spec/Mocks/Methods:stub_chain)

## RSpec2の話

### RSpec1からの主な変更点

- 実行コマンドがspecからrspecに
- Rakeタスクでのオプション指定方法が変更に
  - spec\_opts → rspec\_opts など

- コマンドラインオプションが .rspec ファイルで指定できるように
  - ~/.rspec とプロジェクトのルートにあるものが参照される

#### 参考

- [http://relishapp.com/rspec/rspec-core/file/upgrade](http://relishapp.com/rspec/rspec-core/file/upgrade)

### 新機能いくつか

#### --profileオプション

- 時間がかかったテストを報告してくれる

#### Metadata

- 各exampleがメタデータを持つ
- example内でexample.metadataとして参照可能
- describe, itのオプションとして任意の値を設定可能
- 実行対象の絞り込み等に使える

#### around(:each)

- トランザクションやファイルのオープン・クローズセットなど、なった前処理、後処理を書くのに使える。

```ruby
describe &quot;around hook&quot; do
  around(:each) do |example|
    puts &quot;around each before&quot;
    example.run
    puts &quot;around each after&quot;
  end

  it &quot;gets run in order&quot; do
    puts &quot;in the example&quot;
  end
end
```

### RSpec Rails2

#### have\_tag マッチャが提供されなくなった

- webratのhave\_tag(have\_selector)を使う

```ruby
require &quot;nokogiri&quot;
require &quot;webrat/core/matchers&quot;

RSpec.configure do |config|
  config.include(Webrat::Matchers)
end

it 'aタグの組み立てテスト' do
  tag = '...'
  tag.should have_selector('a', :href =&gt; '...', :content =&gt; 'text')
end
```

#### Rails2系では使えません
> rspec-rails-2 supports rails-3.0.0 and later. For earlier versions of Rails, you need rspec-rails-1.3.
[http://relishapp.com/rspec/rspec-rails](http://relishapp.com/rspec/rspec-rails)

## 参考書籍
- [The RSpec Book: Behaviour Driven Development With RSpec, Cucumber, and Friends](http://www.amazon.co.jp/gp/product/1934356379/ref=as_li_ss_tl?ie=UTF8&tag=htmlmmg-22&linkCode=as2&camp=247&creative=7399&creativeASIN=1934356379) ![](http://www.assoc-amazon.jp/e/ir?t=&l=as2&o=9&a=1934356379)
