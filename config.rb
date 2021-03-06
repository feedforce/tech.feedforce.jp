require 'helpers/custom'

###
# Page URL Path
###
activate :directory_indexes

###
# Middleman Blog Setting
###
activate :blog do |blog|
  Time.zone = 'Tokyo'
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "posts"

  blog.permalink = '{title}.html'
  # Matcher for blog source files
  blog.sources = 'posts/{year}-{month}-{day}-{title}.html'
  blog.taglink = 'category/{tag}/index.html'
  blog.layout = 'blog'
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  blog.default_extension = '.md'

  blog.tag_template = 'category.html'
  # blog.calendar_template = "archive.html"

  # Enable pagination
  blog.paginate = true
  # blog.per_page = 10
  blog.page_link = 'page/{num}'

  blog.new_article_template = 'templates/article.tt'
  blog.publish_future_dated = true
end

page '/feed.xml', layout: false
page '/sitemap.xml', layout: false


###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Autoprefixer
###
activate :autoprefixer do |config|
  config.browsers = ['last 3 versions', 'Explorer >= 8']
end


###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", layout: false
#
# With alternative layout
# page "/path/to/file.html", layout: :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }


###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
activate :livereload

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end


###
# Custom Helper
###
activate :custom_helper

###
# Directory Setting
###
set :css_dir, 'css'
set :js_dir, 'js'
set :images_dir, 'images'
set :layouts_dir, 'layouts'
set :partials_dir, 'partials'
set :helpers_dir, 'helpers'

###
# Build-specific configuration
###
configure :build do
  activate :minify_css
  activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end


###
# Middleman Blog Authors
###
activate :authors do |authors|
  authors.author_path = 'author/:author/index.html'
  authors.author_template = 'author.html'
end

ignore '/author.html'
ignore '/images/retina/*.png'
ignore '/images/sprites/*.png'

###
# Bower Components Support
###
sprockets.append_path '../node_modules'

###
# Markdown Setting
###
set :markdown, tables: true, autolink: true, prettify: true, fenced_code_blocks: true, hard_wrap: true, footnotes: true
set :markdown_engine, :redcarpet

##
# middleman-deploy settings
##
activate :deploy do |deploy|
  deploy.method = :git
  # Project ページであるため 'gh-pages' default
  # Run Automatically
  # deploy.build_before = true
end
