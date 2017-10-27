# 旧 feedforce Engineers' blog [![Circle CI](https://circleci.com/gh/feedforce/tech.feedforce.jp.svg?style=svg)](https://circleci.com/gh/feedforce/tech.feedforce.jp)

[tech.feedforce.jp](http://tech.feedforce.jp)

see: **[How to `developer.feedforce.jp`](https://github.com/feedforce/tech.feedforce.jp/wiki/developer.feedforce.jp)**

## Requirement

* [Node.js](http://nodejs.org/)
* [Ruby](https://www.ruby-lang.org/)

## Getting Setup

    $ ./script/bootstrap

## Middleman Command

### Start Local Server

    $ bundle exec middleman
    or
    $ bundle exec middleman server

### Create a Post

    $ bundle exec middleman article post-name
    == LiveReload accepting connections from http://192.168.1.187:4567 (localhost)
          create  source/posts/YYYY-MM-DD-post-name.html.md

## Add a New Author

Edit `data/author.yml`

## Deployment

### Automatic Publication

:dart: When a Pull request is merged to `master`, CircleCI will build and push to `gh-pages`.

### Pull Request Deployment

:bulb: Every pull request will deploy to https://feedforce-tech-blog-pr-NUMBER.herokuapp.com

### Manual Deployment

:moyai: You can deploy to http://feedforce-tech-blog.herokuapp.com for checking a new article.

* Method1
    * You can deploy in [Heroku console](https://dashboard.heroku.com/apps/feedforce-tech-blog/deploy/github).
* Method2
    * You can deploy using git command.

    ```
    $ git push -f heroku <branch name>:master
    ```
