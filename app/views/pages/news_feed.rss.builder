xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title "News #{Site::DOMAIN}"
    xml.description "News #{Site::DOMAIN}"
    xml.link root_url

    @collection.each do |view|
      xml.item do
        xml.title view.topic_title
        xml.pubDate Time.at(view.created_at.to_i).to_s(:rfc822)
        xml.description format_rss_urls(view.html_body)
        xml.link view.urls.topic_url(protocol: Site::DEFAULT_PROTOCOL)
        xml.guid "entry-#{view.topic.id}"
      end
    end
  end
end
