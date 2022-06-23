# rubocop:disable all

# http://pastebin.com/r2Xz6i0M
# https://www.google.com/search?q=free+proxy+blogspot&rlz=1C5CHFA_enRU910RU910&sxsrf=APq-WBvtLh2iPJ7rqyTXESAfXnHGffsZ0Q%3A1648065445172&ei=pXs7Yo6FCsmEwPAPx4uM0A4&ved=0ahUKEwjO67Obgt32AhVJAhAIHccFA-oQ4dUDCA4&uact=5&oq=free+proxy+blogspot&gs_lcp=Cgdnd3Mtd2l6EAMyBggAEAcQHjIGCAAQCBAeOgcIABBHELADOgcIIxCwAhAnOggIABAHEB4QEzoKCAAQCBAHEB4QEzoICAAQDRAeEBM6CggAEA0QBRAeEBM6CggAEAgQDRAeEBM6DAgAEAgQDRAKEB4QEzoICAAQCBAHEB5KBAhBGABKBAhGGABQoQVYrApgmgtoAXABeACAAWOIAa0DkgEBNZgBAKABAcgBCMABAQ&sclient=gws-wiz
class ProxyParser
  IS_DB_SOURCES = true
  IS_URL_SOURCES = true
  IS_OTHER_SOURCES = true
  IS_CUSTOM_SOURCES = true

  CACHE_VERSION = :v7
  CUSTOM_SORUCES = %i[online_proxy_ru]

  def import
    proxies = fetch(
      is_db_sources: IS_DB_SOURCES,
      is_url_sources: IS_URL_SOURCES,
      is_other_sources: IS_OTHER_SOURCES,
      is_custom_sources: IS_CUSTOM_SOURCES,
      additional_url_sources: [],
      additional_text: ''
    )
    save proxies
  end

  def fetch(
    is_db_sources: IS_DB_SOURCES,
    is_url_sources: IS_URL_SOURCES,
    is_other_sources: IS_OTHER_SOURCES,
    is_custom_sources: IS_CUSTOM_SOURCES,
    additional_url_sources: [],
    additional_text: ''
  )
    parsed_proxies = parse_proxies(
      is_url_sources: is_url_sources,
      is_other_sources: is_other_sources,
      is_custom_sources: is_custom_sources,
      additional_url_sources: additional_url_sources,
      additional_text: additional_text
    )
    db_proxies = is_db_sources ? Proxy.all.map { |v| { ip: v.ip, port: v.port } } : []

    print format("found %<size>i proxies\n", size: parsed_proxies.size)
    print format("fetched %<size>i proxies\n", size: db_proxies.size)

    proxies = (db_proxies + parsed_proxies).uniq(&:to_s)
    print format("%<size>i after merge with previously parsed\n", size: proxies.size)

    verified_proxies = test proxies, Proxies::WhatIsMyIps.call
    print(
      format(
        "%<verified_size>i of %<total_size>i proxies were tested for anonymity\n",
        verified_size: verified_proxies.size,
        total_size: proxies.size
      )
    )

    verified_proxies
  end

  def save proxies
    ApplicationRecord.transaction do
      if proxies.any?
        Proxy.delete_all
        Proxy.import proxies
      end
    end
  end

private

  def parse url, protocol
    # задержка, чтобы не нас не банили
    sleep 1
    proxies = parse_text(
      OpenURI.open_uri(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read,
      protocol
    )
    print "#{url} - #{proxies.size} proxies\n"

    proxies
  rescue StandardError => e
    print "#{url}: #{e.message}\n"
    []
  end

  def parse_text text, protocol
    text
      .gsub(/\d+\.\d+\.\d+\.\d+[:\t\n]\d+/)
      .map do |v|
        data = v.split(/[:\t\n]/)
        Proxy.new ip: data[0], port: data[1].to_i, protocol: protocol
      end
  end

  def test proxies, ips
    proxies = proxies
    verified_proxies = Concurrent::Array.new
    proxies_count = proxies.size

    print "testing #{proxies.size} proxies\n"

    pool = Concurrent::FixedThreadPool.new(Concurrent.processor_count * 20)
    index = Concurrent::AtomicFixnum.new(-1)

    proxies.each do |proxy|
      pool.post do
        current_index = index.increment
        puts "testing #{current_index + 1}/#{proxies_count} proxy #{proxy}"

        verified_proxies << proxy if Proxies::Check.call(proxy: proxy, ips: ips)
      end
    end

    loop do
      sleep 2
      break if pool.queue_length.zero?
    end
    pool.kill

    verified_proxies
  end

  def other_sources
    Rails.cache.fetch([:proxy, :other_sources, CACHE_VERSION], expires_in: 1.hour) do
      getfreeproxylists + webanetlabs
    end
  end

  def webanetlabs
    Nokogiri::HTML(
      OpenURI.open_uri(
        'https://webanetlabs.net/publ/24',
        ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
      ).read
    )
      .css('.uSpoilerText a.link')
      .map { |v| 'https://webanetlabs.net' + v.attr(:href) }
  rescue StandardError => e
    print "webanetlabs: #{e.message}\n"
    []
  end

  def online_proxy_ru url = 'http://online-proxy.ru'
    proxies = parse_text(
      Nokogiri::HTML(OpenURI.open_uri(url).read).text,
      :http
    )

    print "#{url} - #{proxies.size} proxies\n"
    proxies

  rescue StandardError => e
    print "online_proxy_ru: #{e.message}\n"
    []
  end

  def getfreeproxylists url = 'https://getfreeproxylists.blogspot.com/'
    html = Nokogiri::HTML(OpenURI.open_uri(url).read)
    links = html.css('ul.posts a').map { |v| v.attr :href }

    [url] + links
  end

  def parse_proxies(
    is_url_sources:,
    is_other_sources:,
    is_custom_sources:,
    additional_url_sources:,
    additional_text: ''
  )
    url_sourced_proxies = is_url_sources ? (
      URL_SOURCES.flat_map do |url|
        Rails.cache.fetch([url, :proxies, CACHE_VERSION], expires_in: 1.hour) { parse url, :http }
      end
    ) : []
    additional_url_sources_proxies = additional_url_sources.flat_map do |url|
      Rails.cache.fetch([url, :proxies, CACHE_VERSION], expires_in: 1.hour) { parse url, :http }
    end

    other_sourced_proxies = is_other_sources ? (
      other_sources.flat_map do |url|
        Rails.cache.fetch([url, :proxies, CACHE_VERSION], expires_in: 1.hour) { parse url, :http }
      end 
    ) : []

    custom_sourced_proxies = is_custom_sources ? (
      CUSTOM_SORUCES.flat_map do |method|
        Rails.cache.fetch([method, :proxies, CACHE_VERSION], expires_in: 1.hour) { send method }
      end
    ) : []

    (
      url_sourced_proxies +
        additional_url_sources_proxies +
        other_sourced_proxies +
        custom_sourced_proxies + 
        parse_text(additional_text, :http)
    ).uniq
  end

  URL_SOURCES = %w[
    http://proxysearcher.sourceforge.net/Proxy%20List.php?type=http&filtered=true
    https://free-proxy-list.net/
    https://rootjazz.com/proxies/proxies.txt
    http://www.megaproxylist.net/
    http://sslproxies24.blogspot.com/feeds/posts/default
    http://proxylists.net/
    http://my-proxy.com/free-proxy-list-10.html
    http://my-proxy.com/free-proxy-list-2.html
    http://my-proxy.com/free-proxy-list-3.html
    http://my-proxy.com/free-proxy-list-4.html
    http://my-proxy.com/free-proxy-list-5.html
    http://my-proxy.com/free-proxy-list-6.html
    http://my-proxy.com/free-proxy-list-7.html
    http://my-proxy.com/free-proxy-list-8.html
    http://my-proxy.com/free-proxy-list-9.html
    http://my-proxy.com/free-proxy-list.html
    http://atomintersoft.com/anonymous_proxy_list
    http://atomintersoft.com/high_anonymity_elite_proxy_list
    http://atomintersoft.com/index.php?q=proxy_list_domain&domain=com
    http://atomintersoft.com/products/alive-proxy/proxy-list
    http://atomintersoft.com/products/alive-proxy/proxy-list/3128
    http://atomintersoft.com/products/alive-proxy/proxy-list/high-anonymity
    http://atomintersoft.com/products/alive-proxy/socks5-list
    http://atomintersoft.com/proxy_list_domain
    http://atomintersoft.com/proxy_list_domain_com
    http://atomintersoft.com/proxy_list_domain_edu
    http://atomintersoft.com/proxy_list_domain_net
    http://atomintersoft.com/proxy_list_domain_org
    http://atomintersoft.com/proxy_list_port
    http://atomintersoft.com/proxy_list_port_3128
    http://atomintersoft.com/proxy_list_port_80
    http://atomintersoft.com/proxy_list_port_8000
    http://atomintersoft.com/proxy_list_port_81
    http://atomintersoft.com/transparent_proxy_list
    https://proxylistdaily4you.blogspot.com/p/l1l2l3-proxy-server-list-1167.html
    https://www.newproxys.com/free-proxy-lists/
    http://cyber-gateway.net/get-proxy/free-proxy
    http://proxyserverlist-24.blogspot.com/feeds/posts/default
    http://alexa.lr2b.com/proxylist.txt
    https://api.proxyscrape.com/v2/?request=getproxies&protocol=http&timeout=10000&country=all&ssl=all&anonymity=elite&simplified=true&limit=300
    http://multiproxy.org/txt_all/proxy.txt # 0 of 1526
    http://www.cybersyndrome.net/pla6.html
  ]
end
