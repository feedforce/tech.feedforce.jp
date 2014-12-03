xml.instruct!
xml.urlset 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9', 'xmlns:xsi' =>'http://www.w3.org/2001/XMLSchema-instance' do
  sitemap.resources.each do |resource|
    xml.url do
      xml.loc "#{data.site.url}#{resource.url}"
    end if resource.destination_path =~ /\.html$/
  end
end
