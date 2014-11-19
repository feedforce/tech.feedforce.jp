class LangageConverter < Middleman::Extension
  def initialize(app, options_hash={}, &block)
    super
  end

  helpers do
    def slug_to_japanese(en_text)
      jp_text = ''

      data.category.each do |key, value|
        if en_text == key.en then
          jp_text = key.ja
        end
      end

      return jp_text
    end
    def author_info(author_id)
      author_data = []

      data.author.each do |key, value|
        if author_id == key.id then
          author_data = key
        end
      end

      return author_data
    end
    def article_excerpt(article_body)
      excerpt_position = article_body.index('<!--more-->')

      if excerpt_position.nil? then
        return article_body
      end

      return article_body[0, excerpt_position]
    end
  end
end

::Middleman::Extensions.register(:lang_convert, LangageConverter)
