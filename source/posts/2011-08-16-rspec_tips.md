---
title: RSpecの話を少し
date: 2011-08-16 17:22 JST
authors: r-suzuki
tags: ruby, test, resume, 
---
<p>弊社内のRubyを使ったプロジェクトでは、自動テストツールのひとつとしてRSpec(バージョン2と1両方)を使っています。<br />
先日社内勉強会でRSpecのトピックを取り上げたので、いくつか紹介したいと思います。<br />
</p>

<!--more-->

<h2>Tipsなど</h2>

(以下のコードはバージョン1でも動作します)

<h3>as_null_object</h3>

<p>通常、Mockオブジェクトに対してstub定義していないメソッドを呼ぶとMockExpectationErrorが発生します。ですがテストによっては、ある特定のメソッド呼び出し以外を無視したいケースもあるでしょう。（例えばログ出力内容の検証など）<br />
その場合はMockオブジェクトに対してas_null_objectメソッドを呼んでおくことで、特定のメソッド呼び出し以外を無視することができます。</p>

```
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

<h4>参考</h4>

<ul>
<li><a href="http://en.wikipedia.org/wiki/Null_Object_pattern">Null Objectパターン</a></li>
<li><a href="http://rdoc.info/gems/rspec/1.3.2/Spec/Mocks/Methods:as_null_object">Method: Spec::Mocks::Methods#as_null_object</a></li>
</ul>

<h3>Shared Examples</h3>

<p>例えばダックタイピングを適用して、同じように振る舞うクラスを複数実装したとしましょう。その共通する振る舞いのテストコードを別々に用意すると、重複が発生してしまいますし保守が面倒です。<br />
RSpecではそういった共通するexample群に名前を付けて、example group間で共有することができます。</p>

<pre class="prettyprint "><code>
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

<h4>参考</h4>

<ul>
<li><a href="http://rdoc.info/gems/rspec/1.3.2/Spec/DSL/Main:share_examples_for">Method: Spec::DSL::Main#share_examples_for</a></li>
</ul>

<h3>マッチャいろいろ</h3>

<p>「should ==」ばかり使ってテストを書くこともできますが、適したマッチャを使うことでテストの内容がより明確になり、分かりやすい失敗メッセージを得ることができます。</p>

<h4>have(n)</h4>

```

columns = [1, 2, 3]

# これでも悪くはないですが...
columns.size.should == 4      # &quot;expected: 4, got: 3 (using ==)&quot;

# こちらの方が良い
columns.should have(4).items  # &quot;expected 4 items, got 3&quot;

```

<h4>be(*args)</h4>

```

result = 11

# これでも間違いではないですが...
(result &lt; 10).should be_true  # &quot;expected false to be true&quot;

# こちらの方が良い
result.should be &lt; 10         # &quot;expected &lt; 10, got 11&quot;

```

<p>ちなみにbeの実装はMatchers::Beのインスタンスを返してMatchers::Beは演算子"&lt;"の実装をオーバーライドしてるからMatchers::BeComparedToのインスタンスを返して、それがshouldの引数になって...という具合です。</p>

<h3>Stub chain</h3>

<p>stub_chainメソッドを使うことで、あるオブジェクトの関連オブジェクトのさらに関連オブジェクト...のようにネストしたスタブを一度に定義できます。<br />
あまりにネストした関連は設計を改善した方が良さそうですが...。</p>

```

# こう書いても良いが...
boss = mock('ボス', :policy =&gt; 'みんながんばれ')
member.stub!(:boss).and_return(boss)
member.boss.policy  # 'みんながんばれ'

# こう書ける
member.stub_chain(:boss, :policy).and_return('みんながんばれ')
member.boss.policy  # 'みんながんばれ'

```

<h4>参考</h4>

<ul>
<li><a href="http://rdoc.info/gems/rspec/1.3.2/Spec/Mocks/Methods:stub_chain">Method: Spec::Mocks::Methods#stub_chain</a></li>
</ul>

<h2>RSpec2の話</h2>

<h3>RSpec1からの主な変更点</h3>

<ul>
<li>実行コマンドがspecからrspecに</li>
<li>Rakeタスクでのオプション指定方法が変更に<ul>
<li>spec_opts → rspec_opts など</li>
</ul>
</li>
<li>コマンドラインオプションが .rspec ファイルで指定できるように<ul>
<li>~/.rspec とプロジェクトのルートにあるものが参照される</li>
</ul></li>
</ul>

<h4>参考</h4>

<ul>
<li><a href="http://relishapp.com/rspec/rspec-core/file/upgrade">http://relishapp.com/rspec/rspec-core/file/upgrade</a></li>
</ul>

<h3>新機能いくつか</h3>

<h4>--profileオプション</h4>

<ul>
<li>時間がかかったテストを報告してくれる</li>
</ul>

<h4>Metadata</h4>

<ul>
<li>各exampleがメタデータを持つ</li>
<li>example内でexample.metadataとして参照可能</li>
<li>describe, itのオプションとして任意の値を設定可能</li>
<li>実行対象の絞り込み等に使える</li>
</ul>

<h4>around(:each)</h4>

<ul>
<li>トランザクションやファイルのオープン・クローズセットなど、なった前処理、後処理を書くのに使える。</li>
</ul>

```

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

<h3>RSpec Rails2</h3>

<h4>have_tag マッチャが提供されなくなった</h4>

<ul>
<li>webratのhave_tag(have_selector)を使う</li>
</ul>

```

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

<h4>Rails2系では使えません</h4>

<blockquote><p>rspec-rails-2 supports rails-3.0.0 and later. For earlier versions of Rails, you need rspec-rails-1.3.</p></blockquote>

<p><a href="http://relishapp.com/rspec/rspec-rails">http://relishapp.com/rspec/rspec-rails</a></p>

<h2>参考書籍</h2>

<ul>
<li><a href="http://www.amazon.co.jp/gp/product/1934356379/ref=as_li_ss_tl?ie=UTF8&amp;tag=htmlmmg-22&amp;linkCode=as2&amp;camp=247&amp;creative=7399&amp;creativeASIN=1934356379">The RSpec Book: Behaviour Driven Development With RSpec, Cucumber, and Friends</a><img src="http://www.assoc-amazon.jp/e/ir?t=&amp;l=as2&amp;o=9&amp;a=1934356379" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" /></li>
</ul>
