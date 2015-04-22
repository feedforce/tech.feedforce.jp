# feedforce Engineers' blog [![Circle CI](https://circleci.com/gh/feedforce/tech.feedforce.jp.svg?style=svg)](https://circleci.com/gh/feedforce/tech.feedforce.jp)

[tech.feedforce.jp](http://tech.feedforce.jp)

powered by [Middleman](http://middlemanapp.com/)

see: :black_nib: [How to write article](https://github.com/feedforce/tech.feedforce.jp/wiki/%E6%8A%80%E8%A1%93%E8%80%85%E3%83%96%E3%83%AD%E3%82%B0%E8%A8%98%E4%BA%8B%E5%9F%B7%E7%AD%86%E3%83%88%E3%83%A9%E3%81%AE%E5%B7%BB)

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

## Automatic `$ bundle update`

A pull request regularly opens by http://tachikoma.io/

But CircleCI doesn't run at that time. Because the origin of the pull request is from a forked repository.

You can manually run CircleCI. For example of #55,

    $ git remote add -f tachikoma git@github.com:tachikomapocket/feedforce-_-tech.feedforce.jp.git
    $ git checkout -t tachikoma/tachikoma/update-20150205021418
    $ git push origin tachikoma/update-20150205021418
    # => CircleCI starts to run.
