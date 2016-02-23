---
title: ソーシャルPLUSで 1 日 700 通超のアラートメールを撲滅したお話
date: 2016-02-24 15:00 JST
authors: masutaka
tags: operation
---
こんにちは。増田です。
最近は [PS4](http://www.jp.playstation.com/ps4/) と [nasne](http://www.jp.playstation.com/nasne/) を Amazon のショッピングカートに入れては戻す日々を送っています。

さて、私が担当する[ソーシャルPLUS](https://socialplus.jp)では毎日 700 通超のアラートメールに苦しめられてきました。なぜこんなことになってしまったのか...。

しかしながら、この記事はそのメールを（ほぼ）撲滅できたお話です。

Bugsnag については弊社のこちらの記事をどうぞ。

* [Rails のエラー通知を fluentd 経由で Bugsnag に送る | feedforce Engineers' blog](http://tech.feedforce.jp/rails-fluent-bugsnag.html)

<!--more-->

## はじめに

Rails4 デフォルトとソーシャルPLUSの違いを比較します。

### デフォルトの Rails.logger

解説の必要はありませんね :)

```
ActiveSupport::Logger
```

### ソーシャルPLUSの Rails.logger

[Log4r という gem](https://rubygems.org/gems/log4r) を使って[^1]、ファイルとメールの 2 方向に出力しています。

```
Log4r::Logger
├ Log4r::FileOutputter
└ Log4r::SocialplusEmailOutputter
```

* Log4r::Logger が 2 つの outputter を持つ
* error レベル以上であれば、メール送信もされる

[^1]: Log4r gem は 2012 年 1 月以来リリースされていないので、良い子は使ってはいけません

## これまでの例外とエラー処理のパターン

例外とエラーを以下の 4 パターンに分けて整理してみました。ソーシャルPLUSではそれぞれ異なった処理をしていました。

### 例外処理

#### 1. 捕捉できなかった例外

* [exception_notification gem](https://rubygems.org/gems/exception_notification) が捕捉してくれる
* 例外情報をメールに送信

#### 2. 捕捉できた例外

* Rails.logger で必要な情報を渡しつつエラー表示
* ログファイルに複数行出力され、メール送信もされる

```rb
begin
  ...
rescue
  Rails.logger.error("#{self.name}.hoge error #{$!.inspect}:\n" + $!.backtrace.join("\n"))
end
```

### エラー処理

#### 3. ビジネスロジック内エラー

* 前述の「捕捉できた例外」と同じだが、複数行出力されることは少ない
* ログファイルに出力され、メール送信もされる

```rb
if ...
  Rails.logger.error("... is wrong condition")
end
```

#### 4. Gem 内エラー

* （当然だけど）Gem にお任せ
* ログファイルに出力され、メール送信もされる

```rb
Rails.logger.error("error occurs")
```

### 問題点

お気づきかと思いますが、全てメールで通知されます。実に 1 日 700 通超です。ソーシャルPLUSは有名どころのお客様が多く、意外にトラフィックの多いサービスなのです。

また、サービスの特性上しっかりと作りこまれており、少しでも不安な処理には用心深く Rails.logger を使っていました。

時々なら頑張って 700 通全部確認することは出来ますが、毎日は絶対無理です（でした）。そもそも早くバグを直せって話です。

もっとも、全てがソーシャルPLUSのエラーではありません。Gem で冗長に出力されたエラーだったり、プロバイダ（Facebook, Twitter, Google,..）側の問題だったりします。

とは言え、これだけ多いとわけが分からなくなってきます。

## これからの例外とエラー処理のパターン

このようなポリシーを持って、改善しました。

* 例外やエラー情報を Bugsnag に集約する
* Bugsnag は fluentd 経由で送る
    * 後日 td-agent のログを見たら、たまに Bugsnag 側でタイムアウトエラーになってました
    * Rails で Bugsnag に直接送ると、このタイムアウトがビジネスロジックに影響してしまいます
* 既存の Log4r の処理は出来るだけ変更しない
    * 一度に変更すると問題が起きた時に困るため

### 例外処理

#### 1. 捕捉できなかった例外

* Bugsnag にお任せ。[Bugsnag gem](https://rubygems.org/gems/bugsnag) をインストールするだけで良い
* exception_notification gem を捨てられた

#### 2. 捕捉できた例外

* Rails.logger を SocialPlus::ExceptionNotifier[^2] に置き換えた
* 例外はファイルと Bugsnag に送られる

```rb
begin
  ...
rescue
  SocialPlus::ExceptionNotifier.error($!)
end
```

[^2]: SocialPlus::ExceptionNotifier のコードは付録にございます

### エラー処理

#### 3. ビジネスロジック内エラー

* それぞれのエラーに対応した例外クラスを定義した
    * その例外クラスを new しつつ、SocialPlus::ExceptionNotifier[^2] に置き換えた
    * この例外クラスは Bugsnag で一意なエラーとするために必要
* エラー情報はファイルと Bugsnag に送られる

```rb
class WrongError < StandardError; end

...

if ...
  SocialPlus::ExceptionNotifier.error(WrongError.new("... is wrong condition"))
end
```

#### 4. Gem 内エラー

* 変更なし
* Rails.logger 等をそのまま使うので、ファイルとメールに出力される

## 所感

* 例外やエラー情報を Bugsnag に集約できたので、日々何が起きているか把握できる基盤ができた
    * あとは適切に対処するだけ
* 他のエラー処理も、これ Bugsnag に送れるんじゃない？という話をし始めることができている
* 修正は大変だった
    * 100 箇所以上、心を込めて変更した
    * まだ fatal と error だけ。warn や info 等をどうするかは考え中
    * 例外クラスは本当に作る必要があるのだろうか？という自問は常にあった
* そもそも、あとから今回のような対応をするのは大変なので、サービス立ち上げ時期にやるべし

## 付録

### SocialPlus::ExceptionNotifier

* Logger と同じログレベルのモジュールメソッドを用意
* 引数に例外クラスを要求する点が異なる
* Bugsnag と Rails.logger に送信する
* Rails.logger の先でメール送信しないように工夫している

```rb
module SocialPlus
  module ExceptionNotifier
    class << self
      # Bugsnag severity can be `error`, `warning` or `info`.
      # See https://github.com/bugsnag/bugsnag-ruby/tree/v2.8.12

      def debug(exception)
        without_email { Rails.logger.debug(message(exception)) }
      end

      def info(exception)
        Bugsnag.notify(exception, severity: 'info')
        without_email { Rails.logger.info(message(exception)) }
      end

      def warn(exception)
        Bugsnag.notify(exception, severity: 'warning')
        without_email { Rails.logger.warn(message(exception)) }
      end

      def error(exception)
        Bugsnag.notify(exception, severity: 'error')
        without_email { Rails.logger.error(message(exception)) }
      end

      def fatal(exception)
        Bugsnag.notify(exception, severity: 'error')
        without_email { Rails.logger.fatal(message(exception)) }
      end

      private

      def without_email
        original_level = email_outputter.level
        email_outputter.level = Log4r::OFF
        yield
      ensure
        email_outputter.level = original_level
      end

      # 本番環境とステージング環境
      #   Log4r::SocialplusEmailOutputter のインスタンスを返す。
      #
      # 開発環境とテスト環境
      #   level という attr_accessor を持った、上記インスタンスの
      #   替え玉を返す。
      def email_outputter
        @email_outputter ||= (find_email_outputter || dummy_email_outputter)
      end

      def find_email_outputter
        Rails.logger.outputters.find do |outputter|
          outputter.class == Log4r::SocialplusEmailOutputter
        end
      end

      def dummy_email_outputter
        Struct.new(:level).new
      end

      def message(exception)
        result = "#{exception.message} (#{exception.class})"
        result << " #{exception.backtrace.join(' <- ')}" if exception.backtrace
        result
      end
    end
  end
end
```

### Log4r::SocialplusEmailOutputter

```rb
require 'log4r/outputter/outputter'
require 'log4r/outputter/emailoutputter'

module Log4r
  class SocialplusEmailOutputter < Outputter
    attr_reader :subject_prefix, :from, :to, :location, :arguments

    class Skip < StandardError; end

    def initialize(_name, hash = {})
      super(_name, hash)
      validate(hash)
    end

    def validate(hash)
      @from = (hash[:from] or hash['from'])
      raise ArgumentError, "Must specify from address" if @from.nil?
      _to = (hash[:to] or hash['to'] or "")
      @to = Log4rTools.comma_split(_to)
      raise ArgumentError, "Must specify recepients" if @to.empty?

      @subject_prefix = (hash[:subject_prefix] or hash['subject_prefix'] or '')

      @location = (hash[:location] or hash['location'] or '/usr/sbin/sendmail')
      @arguments = (hash[:arguments] or hash['arguments'] or '-i -t')
      @params = { location: @location, arguments: @arguments }
    end

    private

    def canonical_log(logevent)
      synch { write(logevent) }
    end

    def write(logevent)
      send_mail(logevent)
    end

    def send_mail(event)
      msg = @formatter.format(event)
      subject = "#{@subject_prefix} #{LNAMES[event.level]} log report"

      # exclusion_keywords のいずれかにマッチする msg はメール送信しない
      exclusion_keywords = Settings.alert_mail_exclusion.keywords
      if exclusion_keywords.any? { |keyword| msg =~ keyword }
        Bugsnag.notify(Skip.new(msg.chomp), severity: 'info')
        return
      end

      begin
        _sendmail = Mail::Sendmail.new(@params)
        _mail = Mail::Message.new
        _mail.from = @from
        _mail.to = @to
        _mail.subject = subject
        _mail.body = msg
        _sendmail.deliver!(_mail)
      rescue
        Bugsnag.notify($!, severity: 'error')
      end
    end
  end
end
```

* Settings.alert_mail_exclusion.keywords は config/settings.yml に定義しています
* [delayed_job_active_record](https://rubygems.org/gems/delayed_job_active_record) の今のバージョン 4.1.0 は冗長なログを吐くので除外しています

```yaml
alert_mail_exclusion:
  # エラーメッセージがこれらいずれかの正規表現にマッチしたら、メール送信しない
  keywords:
    - !ruby/regexp '/ERROR -- .+ \[Worker\(delayed_job.+ Job .+ FAILED \(\d prior attempts\) with ActiveRecord::StatementInvalid: Mysql2::Error: Deadlock found when trying to get lock; try restarting transaction:/'
    - !ruby/regexp '/ERROR -- .+ \[Worker\(delayed_job.+ Job .+ REMOVED permanently because of \d consecutive failures/'
    - !ruby/regexp '/ERROR -- Mysql2::Error: Deadlock found when trying to get lock; try restarting transaction:/'
```
