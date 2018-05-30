class VideoExtractor::OkExtractor < VideoExtractor::OpenGraphExtractor
  URL_REGEX = %r{
    https?://(?:www\.)?
    (?<hosting>ok).ru/(videoembed|live|video)/(?<key>[\wА-я_-]+)#{PARAMS_REGEXP.source}
  }mix

  def url
    super.gsub %r{/(?:videoembed|live)/}, '/video/'
  end
end
