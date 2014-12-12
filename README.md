# feedforce Engineers' blog

[tech.feedforce.jp](http://tech.feedforce.jp)

powered by [Middleman](http://middlemanapp.com/)

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

Every push to master will deploy to http://feedforce-tech-blog.herokuapp.com

or

Every pull request will deploy to https://feedforce-tech-blog-pr-NUMBER.herokuapp.com

or

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

### Automate Publishing

:dart: When a PR is merged to `master`, CircleCI will build and push it to `gh-pages`.

[![Circle CI](https://circleci.com/gh/feedforce/tech.feedforce.jp.svg?style=svg)](https://circleci.com/gh/feedforce/tech.feedforce.jp)
