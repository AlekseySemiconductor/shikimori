class AnimeVideoDecorator < BaseDecorator
  HOSTINGS_ORDER = {
    'vk.com' => '_' * 1,
    'sovetromantica.com' => '_' * 2,
    'smotret-anime.ru' => '_' * 3,
    'myvi.ru' => '_' * 4,
    'sibnet.ru' => '_' * 5,
    'rutube.ru' => '_' * 6,
  }

  # NOTE: используется в ./app/views/versions/_anime_video.html.slim
  def name
    "episode ##{episode} #{anime.name}"
  end

  def views_count
    if watch_view_count && watch_view_count > 0
      "#{watch_view_count} #{i18n_i 'view', watch_view_count}"
    end
  end

  def player_html
    fixed_url = Url.new(url).without_protocol.to_s if url

    if (hosting == 'myvi.ru' && url.include?('flash')) || (hosting == 'sibnet.ru' && url.include?('.swf?'))
      flash_player_html(fixed_url)
    elsif hosting == 'rutube.ru' && url =~ /\/\/video\.rutube.ru\/(.*)/
      # Простая фильтрация для http://video.rutube.ru/xxxxxxx
      if fixed_url.size > 30
        flash_player_html("//rutube.ru/player.swf?hash=#{$1}")
      else
        h.content_tag(:iframe,
          src: "//rutube.ru/play/embed/#{$1}",
          frameborder: '0',
          webkitAllowFullScreen: 'true',
          mozallowfullscreen: 'true',
          scrolling: 'no',
          allowfullscreen: 'true'
        ) {}
      end
    #elsif hosting == 'youtube.com' && url=~ /youtube\.com\/embed\/(.*)/
      #h.content_tag(:iframe, src: url, frameborder: '0', allowfullscreen: true) {}
    else
      h.content_tag(:iframe,
        src: fixed_url,
        frameborder: '0',
        webkitAllowFullScreen: 'true',
        mozallowfullscreen: 'true',
        scrolling: 'no',
        allowfullscreen: 'true'
      ) {}
    end
  end

  def player_url
    url
  end

  def video_url
    h.play_video_online_index_url anime, episode, id, domain: AnimeOnlineDomain.host(anime), subdomain: false
  end

  def in_list?
    user_rate.present?
  end

  def watched?
    user_rate.episodes >= episode if in_list?
  end

  def user_rate
    @user_rate ||= if h.user_signed_in?
      h.current_user.anime_rates.where(target_id: anime_id, target_type: Anime.name).first
    end
  end

  def add_to_list_url
    h.api_user_rates_path(
      'user_rate[episodes]' => 0,
      'user_rate[score]' => 0,
      'user_rate[status]' => UserRate.statuses[:planned],
      'user_rate[target_id]' => anime.id,
      'user_rate[target_type]' => anime.class.name,
      'user_rate[user_id]' => h.current_user.id
    )
  end

  def viewed_url
    h.viewed_video_online_url(anime, id)
  end

  # сортировка [[озвучка,сабы], [vk.com, остальное], переводчик, язык, качество]
  def sort_criteria
    [
      AnimeVideo.kind.values.index(kind),
      AnimeVideo.language.values.index(language),
      HOSTINGS_ORDER[hosting] || hosting,
      author_name || '',
      AnimeVideo.language.values.index(language),
      AnimeVideo.quality.values.index(quality),
      -id
    ]
  end

  # уникальность по [озвучка, хотинг, переводчик]
  def uniq_criteria
    [
      kind.fandub? || kind.unknown? ? '' : kind,
      vk? ? '' : hosting,
      language_english?,
      author_name || ''
    ]
  end

  def watch_increment_delay
    anime.duration * 60000 / 3 if anime.duration > 0
  end

  def versions
    @versions ||= VersionsQuery.new(object).all
  end

private

  def flash_player_html url
    h.content_tag(:object) do
      h.content_tag(:param, name: 'movie', value: "#{url}") {} +
      h.content_tag(:param, name: 'allowFullScreen', value: 'true') {} +
      h.content_tag(:param, name: 'allowScriptAccess', value: 'always') {} +
      h.content_tag(
        :embed,
        src: "#{url}",
        type: 'application/x-shockwave-flash',
        allowfullscreen: 'true',
        allowScriptAccess: 'always'
      ) {}
    end
  end
end
