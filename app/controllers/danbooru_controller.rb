class DanbooruController < ShikimoriController
  respond_to :json, only: [:autocomplete, :yandere]

  USER_AGENT_WITH_SSL = {
    'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) \
AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36",
    ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
  EXCEPTIONS = [
    Timeout::Error,
    Net::ReadTimeout,
    OpenSSL::SSL::SSLError,
    Errno::ETIMEDOUT,
    Errno::ECONNREFUSED,
    OpenURI::HTTPError
  ]

  def autocomplete
    @collection = DanbooruTagsQuery.new(params[:search]).complete
  end

  def yandere
    Retryable.retryable tries: 2, on: EXCEPTIONS, sleep: 1 do
      url = Base64.decode64 URI.decode(params[:url])
      raise Forbidden, url unless url =~ %r{https?://yande.re}

      json = Rails.cache.fetch "yandere_#{url}", expires_in: 2.weeks do
        open(url, USER_AGENT_WITH_SSL).read
      end

      render json: json
    end
  end

  class << self
    # путь к картинке на s3
    def s3_path(md5)
      "#{request.protocol}d.shikimori.org/#{md5}"
    end

    # путь к картинке на s3
    def filename(md5)
      "#{md5}.jpg"
    end
  end
end
