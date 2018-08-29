class VideoExtractor::VkExtractor < VideoExtractor::BaseExtractor
  URL_REGEX = %r{
    https?://vk.com/video(-?\d+)_(\d+)(?:\?[\w=+%&]+)?
  }xi

  API_URL = 'https://api.vk.com/method/video.get'
  API_VERSION = '5.73'

  TOO_MANY_REQUESTS_EROOR_CODE = 6

  def url
    self.class.normalize_url super
  end

  def image_url
    Url
      .new(parsed_data[:photo_800] || parsed_data[:photo_320])
      .without_protocol
      .to_s
  end

  def player_url
    Url
      .new(parsed_data[:player])
      .without_protocol
      .to_s
      .gsub(/&__ref=[^&]+/, '')
      .gsub(/&api_hash=[^&]+/, '')
  end

  def self.normalize_url url
    url.gsub('http://', 'https://').gsub('//vkontakte.ru', '//vk.com')
  end

  def parse_data json
    json&.dig(:response, :items, 0) || {}
  end

  def fetch_page
    @attempts ||= 1

    json =
      RedisMutex.with_lock('vk_request', block: 1) do
        JSON.parse super, symbolize_names: true
      end

    raise RetryError if json&.dig(:error, :error_code) == TOO_MANY_REQUESTS_EROOR_CODE

    json
  rescue RedisMutex::LockError, RetryError
    @attempts += 1
    return if @attempts >= 10
    sleep 1
    retry
  end

  def video_data_url
    matches = url.match(URL_REGEX)

    API_URL +
      "?videos=#{matches[1]}_#{matches[2]}" \
      "&access_token=#{vk_access_token}" \
      "&v=#{API_VERSION}"
  end

  def vk_access_token
    ENV['VK_USER_ACCESS_TOKEN'] ||
      Rails.application.secrets.oauth[:vkontakte][:user_access_token]
  end
end
