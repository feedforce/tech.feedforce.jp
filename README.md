# feedforce Engineers' blog

powered by [Middleman](http://middlemanapp.com/)

## Requirement

- Ruby
- bundler

```
$ gem install bundler
```

- Node.js
- Bower

```
npm install -g bower
```

## Getting Started

```
$ bower install
$ bundle install --path vendor/bundle
```

## Middleman Command

### Start Local Server

```
$ bundle exec middleman
or
$ bundle exec middleman server
```

### Build

```
$ bundle exec middleman build
```

### Create a Post
```
$ bundle exec middleman article post-name

create source/posts/YYYY-MM-DD-post-name.html.md
```

## Add a New Author

Edit `data/author.yml`
