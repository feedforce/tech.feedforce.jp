---
title: E2E テストを CircleCI 2.0 (Beta) で完結させてみた話
date: 2017-05-08 00:00 JST
authors: ff_koshigoe
tags: test
---

こんにちは、あっという間に社内勉強会の順番がやってきそうでフルえているコシゴエです。気がついたら二年近く会社ブログを書いていませんでした…。

最近、ようやく重い腰を上げて Docker と CircleCI 2.0 を使い始めたので、E2E テストでの活用を試みている話をしたいと思います。

<!--more-->

はじめに
----

突然ですが、弊社プロダクト [dfplus.io](https://dfplus.io/) では、[TestCafe](https://testcafe.devexpress.com/) を使用して E2E テストを自動化しています。

dfplus.io は、異なるリポジトリで管理しているフロントエンド(JS)とバックエンド(Ruby)から構成され、E2E テストはフロントエンドのリポジトリで管理しています。E2E テストはリポジトリへの push をトリガーに [CircleCI](https://circleci.com/) で実行し、このときのバックエンドは E2E 用に用意した共用環境(Heroku 環境)を利用しています。

E2E テストをしばらく運用した結果、いくつかの課題が見えてきました。今回は、その課題を [CircleCI 2.0 Beta](https://circleci.com/beta-access/) を利用して解決を試みた取り組みについて紹介します。


現在 E2E テストで抱えている問題
----

dfplus.io では、E2E テストの自動化を始めて間もなく、十分な知見があるとは言えない状況です。プロダクト開発チームが本質的な問題に集中できる様に、E2E テスト自動化に取り組む時間を捻出して手探りながらも着実に改善を進めていますが、いくつか目に見える問題を抱えています。

- 共用バックエンドの状態に依存するため思わぬところでテストが通らない(20 分待たされたあげくに…)
- E2E テストに時間がかかりすぎる(push の度に 20 分以上待たされる事も…)
- E2E テスト実行スクリプトの今の実装上、対象テストケースを分割した並行実行が行えない(並行実行すれば時間短縮は可能)
- バックエンド実行環境が E2E 実行環境から離れた場所にあり DB アクセス権がない(テストデータセットアップのトリガーが…)


問題解決のアイデア
----

まず、バックエンドが共用である点と、バックエンドが E2E 実行環境から隔離された環境で動いている点について考えます。

CircleCI 2.0 では任意の Docker イメージから作った任意の数のコンテナを動かす事ができるので、各 E2E テスト専用のバックエンドをオンデマンドに動かす事ができます。このバックエンドは E2E テスト実行環境から直接触る事ができる場所で動くため、必要なテストデータを自由にセットアップさせる事もできます。

※ CircleCI 1.0 でも Docker を上手く使えるのかもしれませんが、元々 CircleCI に詳しくなかったため、Docker により近づいた印象を(勝手に)受けた 2.0 を使う事にします。


前提知識：CircleCI 2.0 のさわり
----

前提知識として簡単に CircleCI 2.0 について説明しようと思いましたが、ドキュメントに言語ごとの[チュートリアル](https://circleci.com/docs/2.0/language-ruby/)が用意されているので CircleCI 2.0 をご存じない方はざっと目を通すと概要をつかめると思います。

CircleCI 2.0 では、一度のジョブで行われる一連の流れのほぼ全てを設定ファイル `.circleci/config.yml` に記述する必要があります。CircleCI 1.0 はおおよその流れが決まっていて、適宜オーバーライドする形式なので `circle.yml` に数行書く程度で実行出来ました。1.0 と比べて 2.0 は非常に面倒だと思う方が多いかもしれません。反面、任意のファイルを任意の処理位置でキャッシュし、次回以降のジョブで使い回す事ができるといった面に魅力を感じる方も多いと思います。

また、ジョブを実行する環境として、2.0 では [Docker イメージか今まで同様の VM (Machine) が利用できます](https://circleci.com/docs/2.0/executor-types/)。Docker イメージを使えば、ジョブの実行環境をあらかじめ用意しておく事もできます。[CircleCI から提供されている Docker イメージ](https://circleci.com/docs/2.0/circleci-images/)もあるので、必要に応じて使い分けると良いでしょう。ちなみに、TestCafe を用いた E2E テストにおいては、必要となるものが多いため、CircleCI 提供のイメージをベースとする事をおすすめします。

なお、 `circle.yml` よりも `.circleci/config.yml` が優先されるので、いつでも 1.0 に戻れる様に `circle.yml` を 1.0 の内容で残しておくと良いかもしれません。

※ 真面目に計測していないので正確なデータは出せないのですが、ホストとなるマシンの性能かジョブの隠れたオーバーヘッドが取り除かれるのか、1.0 よりも 2.0 の方がトータルで速いと実感しています。キャッシュが使いやすいからかもしれません。

### 例：node_modules ディレクトリのリストアとキャッシュ

```yaml
# バージョン番号
version: 2
# 任意個のジョブを記述できる(一度に一つのジョブを実行)
jobs:
  # build という名前のジョブがデフォルトで実行される
  build:
    # ジョブの実行環境に Docker を使う
    docker:
      # 一つ目が primary container となり、steps 以下で記述されるコマンドを実行する環境となる
      - image: circleci/node:6.10.2-browsers
      # ポートを EXPOSE している場合、primary container の localhost からフォワードできる様になっている
      # `localhost:6379` で Redis サーバに接続可能
      - image: redis
    ..
    # ジョブで行う事は steps 以下に記述する
    steps:
      ...
      # キーに前方一致するキャッシュがあれば元のパスに復元してくれる
      # Rebuild without cache ボタンではこの手順がスキップされるだけでキャッシュ自体は消えない
      # 手軽にキャッシュを無かった事にしたい場合に備え、以下の様に環境変数を含めるという先人の知恵に習っている
      # http://engineer.crowdworks.jp/entry/2017/04/04/202719
      - restore_cache:
          name: Restore cache
          keys:
            - yarn-{{ .Environment.CACHE_KEY }}-{{ checksum "yarn.lock" }}
            - yarn-{{ .Environment.CACHE_KEY }}-
      - run:
          name: Install npm packages
          command: yarn install --prefer-offline
      - save_cache:
          name: Save cache
          key: yarn-{{ .Environment.CACHE_KEY }}-{{ checksum "yarn.lock" }}
          paths:
            - ~/.cache/yarn
            - ~/app/node_modules
      ...
```


バックエンドのコンテナ化
----

まず大前提として、dfplus.io はコンテナを使った本番運用を行っていません。昔ながらの心温まる EC2(CLB) と [Auto Scaling](https://aws.amazon.com/jp/autoscaling/) で運用しています。今回は、あくまで E2E テストにおけるコンテナ利用のみを考えます。ざっくりと、以下の方針で粛々と作業を進めました。詳細な内容は、Rails をコンテナで動かすという特筆することのない単純なものなので割愛します。

- Alpine Linux を使う
- アプリケーションのソースコードをコンテナに含める
- アプリケーションが依存するパッケージ類(gem など)もコンテナに含める
- アプリケーションが依存するミドルウェアもそれぞれコンテナにする
- レジストリは Amazon ECR を利用する

### 余談：Docker イメージの自動ビルド

ちなみに、バックエンドのコンテナ化作業は CircleCI 2.0 を使い始める前に進めていたため、イメージの自動ビルドには [AWS CodePipeline](https://aws.amazon.com/jp/codepipeline/) ([AWS CodeBuild](https://aws.amazon.com/jp/codebuild/)) を使っています。CodePipeline 設定作業の一連で作った CodeBuild で設定した環境変数を AWS の管理画面から変更できないのが不満ですが、とても簡単に実現できました。
また、GitHub リポジトリへの push をフックに CodePipeline を起動していますが、CodeBuild には S3 経由で zip ファイルが渡ります。この影響で、リポジトリで管理している実行ファイルの実行権限は消える様です。

なお、近々 CircleCI 2.0 に移るかもしれません。


CircleCI 2.0 で Docker コンテナを動かす
----

パブリックレジストリにある Docker イメージを使う場合、設定の `jobs: > {job name}: > docker: > {i}: > image:` でイメージを指定するだけで済みます。一方、 `jobs: > {job name}: > docker: > {i}: > image:` にはプライベートレジストリのイメージは指定できません。自分で認証(`docker login`)を通した上で、適宜イメージを取得(`docker image pull` など)する必要があります。

さらに、CircleCI 2.0 で docker コマンドを実行するためには、[Remote Docker Environment](https://circleci.com/docs/2.0/building-docker-images/) と呼ばれる隔離環境を立ち上げて使用する必要があります。これは steps: 以下に `setup_remote\docker` を記述するだけで準備出来ます。

また、Remote Docker Environment で動くコンテナは、primary container とは異なるネットワークに所属します。primary container から Remote Docker Environment で動くコンテナへの直接的なネットワーク通信は行えません。[通信したいコンテナが属するネットワークに参加する形で新しくコンテナを作り、その新しく作ったコンテナから通信する必要があります](https://circleci.com/docs/2.0/building-docker-images/#accessing-services)。

今回のケースでは、プライベートレジストリを利用する都合とネットワーク的な制約を抱えています。バックエンドのコンテナ群を動かして E2E テストで利用するために、E2E テストも Remote Docker Environment のコンテナで実行する必要がありました。

制約といえば、primary container のファイルシステムを Remote Docker Environment のコンテナからマウントする事もできません。primary container のキャッシュは便利ですが、そのキャッシュを Remote Docker Environment でも無条件に利用する事はできません。直接マウントはできないので、[`docker cp` でコンテナにコピーする方法が提案されています](https://circleci.com/docs/2.0/building-docker-images/#mounting-folders)。

なお、当然ながら、primary container となるイメージには Docker がインストールされている必要があります。primary container 上で直接コンテナを動かす事は無いので、Docker デーモンが動いている必要はありません。

### 例：バックエンドのコンテナ群を動かして E2E テスト

```yaml
# .circleci/config.yml
jobs:
  build:
    ...
    steps:
      ...
      # E2E テストはジョブを分けておくのでここで enqueue する。
      - deploy:
          name: Enqueue E2E Test
          command: |
            curl --fail --user ${CIRCLE_API_TOKEN}: \
              --data build_parameters[CIRCLE_JOB]=e2e \
              --data revision=${CIRCLE_SHA1} \
              https://circleci.com/api/v1.1/project/github/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/tree/${CIRCLE_BRANCH}

  # E2E テストのためのジョブ(build とは別)
  e2e:
    ...
    steps:
      ...
      # バックエンドサーバをコンテナで動かすために Remote Docker Environment を立ち上げる。
      - setup_remote_docker:
          # Remote Docker Environment を使い回せるようにしておく。
          reusable: true
      # イメージを取得するためにプライベートレジストリにログインしておく。
      - run:
          name: Login to Amazon ECR
          command: eval $(aws ecr get-login --region ap-northeast-1)
      ...
      # primary container のディレクトリをマウントさせることができないので、コンテナには docker cp でファイルをコピーするためにここでコンテナを作っておく。
      - run:
          name: Create container for E2E Test
          command: docker-compose -f .circleci/docker-compose.yml create --force-recreate e2e
      # チェックアウトしたソースやキャッシュなど primary container のものを流用するために docker cp でコンテナにコピー。
      - run:
          name: Copy files to E2E Test container
          command: |
            docker cp -L /home/circleci/.yarn e2e:/home/circleci/.yarn
            docker cp -L /home/circleci/app/. e2e:/home/circleci/app
      # E2E テストで必要なシードデータを投入する。DB 起動待ちはエントリポイント経由で行っている。
      - run:
          name: Setup DB
          command: docker-compose -f .circleci/docker-compose.yml run --rm -e FIXTURE_PATH=db/fixtures/e2e api db:setup
      # バックエンド起動後、API サーバが応答可能になるまで待つ必要があるため、curl でリトライしている。
      - run:
          name: Start up containers
          command: |
            docker-compose -f .circleci/docker-compose.yml up -d
            docker container run --rm --network container:api appropriate/curl --retry 10 --retry-delay 1 --retry-connrefused http://localhost:3333/heartbeat
      # docker cp したのでパーミッションを調整した上で E2E テストをコンテナで実行する。
      - run:
          name: Run yarn e2e
          command: |
            docker-compose -f .circleci/docker-compose.yml exec e2e sudo chown -R circleci:circleci /home/circleci
            docker-compose -f .circleci/docker-compose.yml exec e2e /home/circleci/.yarn/bin/yarn e2e
      # スクリーンショットはコンテナに保存されているので、テスト終了後に取り出す必要がある。
      - run:
          name: Copy screenshots from E2E Test container
          command: docker cp e2e:/home/circleci/app/screenshots screenshots
      - store_artifacts:
          path: /home/circleci/app/screenshots
```

```yaml
# .circleci/docker-compose.yml
version: '3'
services:
  postgres:
    image: postgres
  redis:
    image: redis
  job: &job
    image: ...
    depends_on:
      - postgres
      - redis
    # DB 接続できる様になる前にコマンドを実行しない様に待つ。
    entrypoint: ./bin/wait-for-it.sh postgres:5432 -q -s -t 120 -- bundle exec rails
    command: ['jobs:work']
    environment:
      DATABASE_URL: postgres://postgres@postgres/dfplusio
      REDIS_URL: redis://redis:6379
  api:
    <<: *job
    container_name: api
    command: ['s', '-p', '3333', '-b', '0.0.0.0']
    ports:
      - "3333:3333"
  e2e:
    image: feedforce/dfplusio-circleci-node:6.10.2-browsers
    # docker cp しやすいように名前を付ける。
    container_name: e2e
    working_dir: /home/circleci/app
    # up した時と同じコンテナを使いやすい様に待機のためだけのコマンドを実行しておく。
    command: tail -f /dev/null
    environment:
      ...
```

### 余談：DB 起動待ち

DB の起動待ちは、[docker-compose のドキュメント](https://docs.docker.com/compose/startup-order/)で紹介されていた[`wait-for-it.sh`](https://github.com/vishnubob/wait-for-it)を使ってみました。

### 余談：レイヤーキャッシュ

通常、Remote Docker Environment は使い捨ての環境です。このため、ジョブの実行で作られるイメージレイヤーは他のジョブで使い回す事ができません。これを改善するためには、CircleCI に申請をしてホワイトリストに登録してもらう必要があります。

> $ Potential Premium Feature Notice: Docker Layer Caching
> During the CircleCI 2.0 Beta we are providing early access, for no additional charge, to features (including Docker Layer Caching) that may be available for additional fees after the Beta. We welcome your feedback on this and all other aspects of CircleCI 2.0.
>
> Note: This feature only works with whitelisted projects. To get it enabled, please contact your Customer Success manager (email cs@circleci.com and include a link to the project on CircleCI).
>
> [Docker Layer Caching](https://circleci.com/docs/2.0/docker-layer-caching/)

将来的な価格などは分かりませんが、試しに申請したところ一営業日程度で利用できる様になりました。前回ジョブ実行時の状態が保持されているため、イメージ取得やビルドに使っていた6分くらいが丸ごと削減できました。これはお得です。

※ 詳しい実態や Parallelism と組み合わせたときの副作用などについては、まだ未検証です。


CircleCI 2.0 で TestCafe を動かすコンテナのイメージ
----

今回のケースでは、以下をインストールしたイメージが必要となりました。

- Node.js
    - TestCafe やフロントエンドを動かすために使用
- Google Chrome
    - TestCafe のテストケースを動かすブラウザとして使用
- Xvfb
    - Google Chrome の仮想ディスプレイとして使用
- fluxbox (window manager)
    - TestCafe のスクリーンショット機能で使用
- 日本語フォント
    - 日本語表示の画面をスクリーンショットを保存する際に文字化けしない様に

手間を省くために primary container のイメージを流用するなら、Docker や awscli も必要になります。イメージの大きさは気になりますが、レイヤーキャッシュの効果で無視できます。

現時点では、 `circleci/node:6.10.2-browsers` をベースに、fluxbox と日本語フォントと awscli を追加したイメージを利用しています。

ちなみに、E2E テストではない Lint やユニットテストを行うジョブでも同じベースを使っています。[flow-bin](https://github.com/flowtype/flow-bin) が依存している libelf-dev のみ追加しています。

### 余談：flow-bin と ENOENT

flow-bin を使って Alpine Linux で flow を動かそうとすると、依存関係の問題で ENOENT エラーになります。flow-bin が要求するのが libelf.so.1 ですが、Alpine Linux に入るのは libelf.so.0 です。また、libelf の他に、glibc 系の依存問題もあるようです。

```
/app # ldd node_modules/flow-bin/flow-linux64-v0.44.0/flow
        /lib64/ld-linux-x86-64.so.2 (0x55aaa057e000)
        libpthread.so.0 => /lib64/ld-linux-x86-64.so.2 (0x55aaa057e000)
Error loading shared library libelf.so.1: No such file or directory (needed by node_modules/flow-bin/flow-linux64-v0.44.0/flow)
        libm.so.6 => /lib64/ld-linux-x86-64.so.2 (0x55aaa057e000)
        libdl.so.2 => /lib64/ld-linux-x86-64.so.2 (0x55aaa057e000)
        libc.so.6 => /lib64/ld-linux-x86-64.so.2 (0x55aaa057e000)
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: elf_strptr: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: __fprintf_chk: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: __printf_chk: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: __memcpy_chk: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: elf_kind: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: __vsnprintf_chk: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: __recv_chk: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: __read_chk: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: gelf_getshdr: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: __recvfrom_chk: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: elf_version: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: elf_end: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: __realpath_chk: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: __snprintf_chk: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: elf_nextscn: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: __memmove_chk: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: elf_begin: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: elf_getshstrndx: symbol not found
Error relocating node_modules/flow-bin/flow-linux64-v0.44.0/flow: __fdelt_chk: symbol not found
```

- [Flow\-bin exiting with ENOENT in alpine docker container · Issue \#3649 · facebook/flow](https://github.com/facebook/flow/issues/3649)
- [GLIBC symbols not found · Issue \#149 · gliderlabs/docker\-alpine](https://github.com/gliderlabs/docker-alpine/issues/149)


並行実行のための対象ファイル群の分割
----

本題から若干それるため簡単な紹介程度となりますが、CircleCI 2.0 では circleci コマンドを利用してファイル群を分割する事ができます。コマンド `circleci test split` を実行すると、リストをコンテナ数で分割してコンテナ番号に該当する範囲を返します。分割方式を選ぶことができるので、詳しくはドキュメントをご覧ください。

- [Parallelism with CircleCI CLI](https://circleci.com/docs/2.0/parallelism-faster-jobs/)

なお、 `ruby:2.4.1-alpine` を指定した primary container で何も準備せず circleci コマンドを使えたので、ジョブ起動時点で自動的にインストールされる様です。

### 例

```yaml
      - run:
          name: Run rubocop
          command: |
            bundle exec rubocop -L \
                | circleci tests split --split-by=filesize \
                | tee -a /dev/stderr \
                | xargs bundle exec rubocop --fail-fast
      - run:
          name: Run rspec
          command: |
            circleci tests glob "spec/**/*_spec.rb" \
                | circleci tests split --split-by=timings --timings-type=filename \
                | tee -a /dev/stderr \
                | xargs bundle exec rspec
```


まとめ
----

バックエンドをコンテナ化し、E2E テストを CircleCI 2.0 内で完結させた取り組みについて紹介させていただきました。

まだ『最低限のことができる様になった、できる事が分かった』という段階で、本当に効率的で生産的な E2E テストの自動化に繋がるかはこれからの取り組み次第です。CircleCI 2.0 もベータ期間中なので、今後の変更に合わせて何か良い事・悪い事があるかもしれません。

現時点では、目的を達成できたことと一定の成果を社内外にアピールできたことの達成感に浸り、トクホペプシで一人乾杯したいと思っております。

- E2E テスト実行単位で使える独立したバックエンドのコンテナ群を用意した
- E2E テスト実行前に、任意の E2E 用テストデータをセットアップできる様にした
- CircleCI 2.0 でバックエンドコンテナ群を動かせる様にした
- CircleCI 2.0 内で E2E テストを完結させた
- E2E テストランナーが対象テストを指定できる様にさえなれば、CircleCI で並行実行できる様になっている
- CircleCI 2.0 のレイヤーキャッシュオプションが使える事もあり、トータルで 1.0 時代より 5 分程度は時間短縮できている
