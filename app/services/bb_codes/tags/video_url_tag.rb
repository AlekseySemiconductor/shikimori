class BbCodes::Tags::VideoUrlTag
  include Singleton

  MAXIMUM_VIDEOS = 30
  PREPROCESS_REGEXP = %r{\[url=(?<url>#{VideoExtractor.matcher})\].*?\[/url\]}mi
  VIDEO_REGEXP = /(?<text>[^"\]=]|^)(?<url>#{VideoExtractor.matcher})/mi

  def format text
    times = 0

    preprocess(text).gsub VIDEO_REGEXP do
      is_youtube = $LAST_MATCH_INFO[:url].include? 'youtube.com/'
      times += 1 unless is_youtube

      if times <= MAXIMUM_VIDEOS || is_youtube
        $LAST_MATCH_INFO[:text] + to_html($LAST_MATCH_INFO[:url])
      else
        $LAST_MATCH_INFO[:text] + $LAST_MATCH_INFO[:url]
      end
    end
  end

  def preprocess text
    text.gsub PREPROCESS_REGEXP do
      "#{$LAST_MATCH_INFO[:url]} "
    end
  end

private

  def to_html url
    video = Video.new url: url
    return url unless video.hosting.present?

    Slim::Template
      .new("#{Rails.root}/app/views/videos/_video.html.slim")
      .render(OpenStruct.new(video: video))
  end
end
