xml.instruct!
xml.feed 'xmlns' => 'http://www.w3.org/2005/Atom' do
  xml.title data.site.name
  xml.subtitle data.site.description
  xml.id data.site.url
  xml.link 'href' => data.site.url
  xml.link 'href' => data.site.url, 'rel' => 'self'
  xml.updated(blog.articles.first.date.to_time.iso8601) unless blog.articles.empty?
  xml.author { xml.name data.site.author }

  blog.articles[0..15].each do |article|
    xml.entry do
      xml.title article.title
      xml.link 'rel' => 'alternate', 'href' => URI.join(data.site.url, article.url)
      xml.id URI.join(data.site.url, article.url)
      xml.published article.date.to_time.iso8601
      # xml.updated File.mtime(article.source_file).iso8601
      xml.updated article.date.to_time.iso8601
      xml.author { xml.name article.data.authors }
      # xml.summary article.summary, 'type' => 'html'
      xml.content article.body, 'type' => 'html'
    end
  end
end
