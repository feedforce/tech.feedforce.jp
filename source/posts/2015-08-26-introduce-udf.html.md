---
title: BigQueryで待望のUDFがリリースされたので早速試してみた
date: 2015-08-26 04:35 JST
authors: yukiyan
tags: BigQuery
---

![UDF Release](/images/2015/08/udf-release.png)

ゆきやんです！ ついに出ました！！ UDF！！！
前回の私の投稿では弊社での[BigQueryの導入事例](http://tech.feedforce.jp/bigquery_tips.html)をご紹介いたしました。
今回は、[今朝リリース](http://googledevelopers.blogspot.jp/2015/08/breaking-sql-barrier-google-bigquery.html)されたBigQueryの新機能であるUDFについて書きたいと思います。

<!--more-->

## UDFとは
UDF(user-defined function)とは、BigQueryで実行するクエリ内にJavaScriptを書いて任意のロジックが実行できるようになる機能です。
この機能によって、BigQueryで扱えるデータの幅がグッと広がります。

## UDFはすぐに試せる
UDFを用いたクエリの実行は、以下のようにBigQueryのWebUIからすぐに試すことができます。

Query Editorでは、クエリを入力します。
![クエリ入力画面](/images/2015/08/query-web-ui.png)

UDF Editorでは、UDFを入力します。
![UDF入力画面](/images/2015/08/udf-web-ui.png)


## 実際に使ってみる
UDFの使い方を説明する前に、まずは実際に使ってみましょう。
では、ある数値をカンマ区切りの金額表示形式に変換しようと思います。
(例: 15000 -> ¥15,000)

### UDFなしで書いた場合
まずは、UDFなしで書いてみます。
だいぶ無理のあるクエリですが以下のように書けます。しかも、この場合7桁までしか対応できません。

```sql
SELECT
CASE
    WHEN length(number) <= 3
      THEN number
    WHEN length(number) <= 4
      THEN '¥' + REGEXP_REPLACE(number, r'(\d)(\d\d\d)', r'\1' + ',' + r'\2')
    WHEN length(number) <= 5
      THEN '¥' + REGEXP_REPLACE(number, r'(\d\d)(\d\d\d)', r'\1' + ',' + r'\2')
    WHEN length(number) <= 6
      THEN '¥' + REGEXP_REPLACE(number, r'(\d\d\d)(\d\d\d)', r'\1' + ',' + r'\2')
    WHEN length(number) <= 7
      THEN '¥' + REGEXP_REPLACE(number, r'(\d)(\d\d\d)(\d\d\d)', r'\1' + ',' + r'\2' + ',' + r'\3' )
    ELSE
    "不正な値"
    END AS price
from
( SELECT number FROM (SELECT '15000' AS number) )
```

### UDFありで書いた場合
クエリからUDFとして定義した関数を呼ぶことで、JavaScriptを実行できます。
先ほどと違い、何桁の場合でも対応できますし、クエリもシンプルになり可読性が上がりました！

クエリ

```sql
SELECT
  '¥' + price
FROM
  moneyLocale( (SELECT number FROM (SELECT '15000' AS number)) )
```

UDF

```js
function moneyLocale(row, emit) {
  emit({price: localeHelper(row.number)});
}

function localeHelper(num) {
  try {
    var str = String(num).split("").reverse().join("").match(/\d{1,3}/g).join(",").split("").reverse().join("");
    return str;
  } catch (ex) {
    return num;
  }
}

bigquery.defineFunction(
  'moneyLocale',
  ['number'],
  [{name: 'price', type: 'string'}],
  moneyLocale
);
```

## UDFの定義方法
では、実際にUDFはどのように定義するのか説明いたします。
基本的には以下の構成になります。

```js
function UDFName(row, emit) {
  emit({name: 'row.<col1>やrow.<col2>を処理する'}); // 処理対象のそれぞれの列
}

bigquery.defineFunction(
  'UDF_name',  // クエリ内での参照名
  ['<col1>', '<col2>'],  // 処理対象にしたいテーブルのカラム名
  [{name: 'name', type: 'string'}], // 処理結果のカラム名と型
  UDFName // UDFとして定義したfunction名
);
```

先ほどの例で説明すると以下のようになります。
例外が発生するとUDFだけでなくクエリ全体が失敗となってしまうので、例外処理を追加しエラーハンドリングを行っています。

```js
// UDFの定義
function moneyLocale(row, emit) {
  emit({price: localeHelper(row.number)});
}

// 例外処理用のヘルパー
function localeHelper(num) {
  try {
    var str = String(num).split("").reverse().join("").match(/\d{1,3}/g).join(",").split("").reverse().join("");
    return str;
  } catch (ex) {
    return num;
  }
}

// BigQueryのクエリで呼び出せるようにする処理
bigquery.defineFunction(
  'moneyLocale', // クエリ内での参照名
  ['number'], // 処理対象にしたいテーブルのカラム名
  [{name: 'price', type: 'string'}], // 処理結果のカラム名と型
  moneyLocale // UDFとして定義したfunction名
);
```

## API経由でUDFを使う
WebUIのほかに、APIでもUDFを実行できます。
以下、Rubyで書いたコード例です。
gemは、[google/google-api-ruby-client](https://github.com/google/google-api-ruby-client)を用いました。
また、UDFはコード内にインラインで書けますが、Google Cloud Storage(GCS)経由でも読み込めます。

```ruby
require 'google/api_client'

class UdfSample
  def initialize
    @client = Google::APIClient.new(application_name: 'sample', application_version: '0.0.1')
    authorize
    @api    = @client.discovered_api('bigquery', 'v2')
  end

  def run
    response = execute_query
    response = poll(response.data.jobReference.jobId)
    puts result(response.data.jobReference.jobId)
  end

  private

  def authorize
    scope  = [
      'https://www.googleapis.com/auth/bigquery',
      'https://www.googleapis.com/auth/cloud-platform',
      'https://www.googleapis.com/auth/devstorage.read_only',
      'https://www.googleapis.com/auth/devstorage.read_write',
      'https://www.googleapis.com/auth/devstorage.full_control'
    ]
    key = Google::APIClient::KeyUtils.load_from_pkcs12(ENV['P12_PATH'], 'notasecret'))

    @client.authorization = Signet::OAuth2::Client.new(
    token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
    audience: 'https://accounts.google.com/o/oauth2/token',
    scope: scope,
    issuer: ENV['issuer'],
    signing_key: key)

    @client.authorization.fetch_access_token!
  end

  def execute_query
    @client.execute(set_insert_params)
  end

  def poll(job_id)
    response = @client.execute(set_get_params(job_id))

    while response.data.status.state != 'DONE'
      sleep 30
      response = @client.execute(set_get_params(response.data.jobReference.jobId))
    end
  end

  def result(job_id)
    response = @client.execute(set_result_params(job_id))
    response.data.rows[0].f[0].v
  end

  def set_insert_params
    {
      api_method: @api.jobs.insert,
      parameters: {
        projectId: 'sample_project'
      },
      body_object: {
        configuration: {
          query: {
            userDefinedFunctionResources: [
              {
                inlineCode: udf
              }
              # UDFはGCS経由でも読み込めます。
              # {
              #   resourceUri: 'gs://some-bucket/js/lib.js'
              # }
            ],
            query: query
          }
        }
      }
    }
  end

  def set_get_params(job_id)
    {
      api_method: @api.jobs.get,
      parameters: {
        projectId: 'sample_project', jobId: job_id
      }
    }
  end

  def set_result_params(job_id)
    {
      api_method: @api.jobs.get_query_results,
      parameters: {
        projectId: 'sample_project', jobId: job_id
      }
    }
  end

  def udf
    "function moneyLocale(row, emit) {
      emit({price: localeHelper(row.number)});
    }

    function localeHelper(num) {
      try {
        var str = String(num).split('').reverse().join('').match(/\d{1,3}/g).join(',').split('').reverse().join('');
        return str;
      } catch (ex) {
        return num;
      }
    }

    bigquery.defineFunction(
      'moneyLocale',
      ['number'],
      [{name: 'price', type: 'string'}],
      moneyLocale
    );"
  end

  def query
    "SELECT
      '¥' + price
    FROM
      moneyLocale( (SELECT number FROM (SELECT '15000' AS number)) )"
  end
end

UdfSample.new.run
# => ¥15,000
```

## 感想
BigQueryに関わっているチームメンバーは皆、川のようなクエリで消耗しているのでUDFに対する期待は大です。
今後、プロダクション利用できるようさらに知見を深めていこうと思います。

## 参考資料
* [BigQuery User-Defined Functions - BigQuery — Google Cloud Platform](https://cloud.google.com/bigquery/user-defined-functions)
* [Google Cloud Platform Blog: Google BigQuery adds UDF support for deeper cloud analytics](http://googlecloudplatform.blogspot.jp/2015/08/Google-BigQuery-adds-UDF-support-for-deeper-cloud-analytics.html)
* [Google Developers Blog: Breaking the SQL Barrier: Google BigQuery User-Defined Functions](http://googledevelopers.blogspot.jp/2015/08/breaking-sql-barrier-google-bigquery.html)
