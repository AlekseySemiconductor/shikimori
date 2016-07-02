class VideoExtractor::UrlExtractor < ServiceObjectBase
  HTTP = %r{(?:https?:)?//(?:www\.)?}.source
  CONTENT = /[^" ><\n]+/.source
  PARAM = /[^" ><&\n]+/.source
  SMOTRET_ANIME_REGEXP = %r(
    #{HTTP}smotret-anime.ru
      (?:
        /catalog/[\w-]+/[\w-]+/[\w-]+?-(?<id>\d+)
        |
        /translations/embed/(?<id>\d+)
      )
  )mix

  pattr_initialize :content

  def call
    if parsed_url
      fixed_url = parsed_url
        .gsub('&amp;', '&')
        .sub(%r{[\]\[=\\]+$}, '')
        .sub(%r{\|.*}, '')

      Url.new(fixed_url).without_protocol.to_s
    else
      data = VideoExtractor.fetch url
      data.player_url if data
    end
  end

private

  def url
    @url ||= @content.to_s.strip
  end

  def html
    @hmtl ||= if url =~ %r{^https?://[^ <>"]+$}
      "src=\"#{url}\""
    else
      url
    end
  end

  def parsed_url
    if html =~ %r{(#{HTTP}(?:vk.com|vkontakte.ru)/video_ext#{CONTENT})}
      $1.sub(/&(amp;)?hd=\d/, '')
    #elsif html =~ %r{(#{HTTP}myvi.ru/(?:ru/flash/)?player#{CONTENT})}
      #$1
    #elsif html =~ %r{(#{HTTP}myvi.tv/embed/html/#{CONTENT})}
      #$1
    elsif html =~ %r{#{HTTP}myvi.(ru|tv)/(#{CONTENT}/)+(preloader.swf\?id=)?(?<hash>#{CONTENT})}
      "http://myvi.ru/player/embed/html/#{$~[:hash]}"
    elsif html =~ %r{(#{HTTP}(api.video|videoapi.my).mail.ru/videos#{CONTENT})}
      $1.gsub('api.video', 'videoapi.my')
    elsif html =~ %r{(#{HTTP}img.mail.ru/r/video2/player_v2.swf\?#{CONTENT})}
      $1
    elsif html =~ %r{(#{HTTP}my.mail.ru/mail/(?<user>#{PARAM})/video/(?<ids>#{PARAM}/#{PARAM}).html)}
      "https://videoapi.my.mail.ru/videos/embed/mail/#{$~[:user]}/#{$~[:ids]}.html"
    elsif html =~ %r{movieSrc=(#{CONTENT})"}
      "http://videoapi.my.mail.ru/videos/embed/#{$1.sub(/&autoplay=\d/, '')}.html"
    elsif html =~ %r{(#{HTTP}rutube.ru/(?:video/embed|embed)#{CONTENT})}
      $1
    elsif html =~ %r{(#{HTTP}video.rutube.ru/#{CONTENT})}
      $1
    elsif html =~ %r{#{HTTP}rutube.ru/tracks/#{PARAM}\.html\?v=(#{PARAM})}
      "http://video.rutube.ru/#{$1}"
    elsif html =~ %r{(#{HTTP}video.sibnet.ru/shell#{CONTENT})}
      $1.sub(/shell\.swf\?/, 'shell.php?')
    elsif html =~ %r{#{HTTP}data\d+\.video.sibnet.ru/\d+/\d+(?:/\d+)?/(#{CONTENT}).(?:mp4|flv)}
      "http://video.sibnet.ru/shell.php?videoid=#{$1.sub(/\.(flv|mp4)\?.*/, '')}"
    elsif html =~ %r{(#{HTTP}v.kiwi.\w+/(?:v|v2)/#{CONTENT})}
      $1
    elsif html =~ %r{(#{HTTP}p.kiwi.\w+/static/player2/player.swf\?config=#{CONTENT})}
      $1
    elsif html =~ %r{(#{HTTP}youtube.com/(?:embed|v)/#{CONTENT})}
      $1.sub(/^\/\//, 'http://')
    elsif html =~ %r{(#{HTTP}i.i.ua/video/evp.swf\?#{CONTENT})}
      $1
    elsif html =~ %r{(#{HTTP}video.yandex.ru#{CONTENT})}
      $1
    elsif html =~ %r{(#{HTTP}flashx.tv#{CONTENT})}
      $1
    elsif html =~ %r{(#{HTTP}vidbull.com#{CONTENT})}
      $1
    elsif html =~ %r{(#{HTTP}mipix.eu#{CONTENT})}
      $1
    elsif html =~ SMOTRET_ANIME_REGEXP
      "https://smotret-anime.ru/translations/embed/#{$~[:id]}"
    elsif html =~ VideoExtractor::OpenGraphExtractor::RUTUBE_SRC_REGEX
      "http://rutube.ru/play/embed/#{$1}"
    elsif html =~ %r{#{HTTP}play.aniland.org/(\w+)}
      "http://play.aniland.org/#{$1}?player=8"

    #elsif html =~ %r{(?:https?:)?//animeonline.su/player/videofiles}
      #puts 'animeonline.su skipped' unless Rails.env.test?
      #nil

    #elsif html =~ %r{(?:https?:)?//clipiki.ru/flash}
      #puts 'clipiki.ru skipped' unless Rails.env.test?
      #nil

    #elsif html =~ %r{\bi.ua/video/}
      #puts 'i.ua skipped' unless Rails.env.test?
      #nil

    #elsif html =~ %r{(?:https?:)?//(?:vk.com|vkontakte)/video\?q}
      #puts 'vk direct link skipped' unless Rails.env.test?
      #nil

    else
      puts "can't extract video url: '#{html}'" unless Rails.env.test?
      nil
    end
  end
end
