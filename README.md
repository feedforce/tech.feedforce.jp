# feedforce Engineers' blog

powered by [Middleman](http://middlemanapp.com/)

## Requirement

* [Node.js](http://nodejs.org/)
* [Ruby](https://www.ruby-lang.org/)

## Getting Started

    $ ./script/bootstrap

## Middleman Command

### Start Local Server

    $ bundle exec middleman
    or
    $ bundle exec middleman server

### Build

    $ bundle exec middleman build

### Create a Post

    $ bundle exec middleman article post-name
    == LiveReload accepting connections from http://192.168.1.187:4567 (localhost)
          create  source/posts/YYYY-MM-DD-post-name.html.md

## Add a New Author

Edit `data/author.yml`

## Deployment

Every push to master will deploy to http://feedforce-tech-blog.herokuapp.com
