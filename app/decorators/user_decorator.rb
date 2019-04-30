class UserDecorator < BaseDecorator
  instance_cache :clubs_for_domain, :exact_last_online_at,
    :is_friended?, :mutual_friended?, :stats

  def self.model_name
    User.model_name
  end

  def clubs_for_domain
    object
      .clubs
      .where(locale: h.locale_from_host)
      .decorate
      .sort_by(&:name)
  end

  def url
    h.profile_url(
      will_save_change_to_nickname? ? to_param(changes['nickname'][0]) : self,
      subdomain: false
    )
  end

  def edit_url page:
    h.edit_profile_url(
      will_save_change_to_nickname? ? to_param(changes['nickname'][0]) : self,
      page: page
    )
  end

  def show_contest_link?
    (can_vote_1? || can_vote_2? || can_vote_3?) && notification_settings_contest_event?
  end

  def unvoted_contests
    [can_vote_1?, can_vote_2?, can_vote_3?].count { |v| v }
  end

  # добавлен ли пользователь в друзья текущему пользователю
  def is_friended?
    h.current_user&.friend_links&.any? { |v| v.dst_id == id }
  end

  def mutual_friended?
    is_friended? && friended?(h.current_user)
  end

  def stats
    Rails.cache.fetch [:profile_stats, object, :v3] do
      profile_stats = Users::ProfileStatsQuery.new(object).to_profile_stats
      Profiles::StatsView.new(profile_stats)
    end
  end

  def exact_last_online_at
    return Time.zone.now if new_record?

    cached = ::Rails.cache.read(last_online_cache_key)
    cached = Time.zone.parse(cached) if cached
    [cached, last_online_at, current_sign_in_at, created_at].compact.max
  end

  def last_online
    if object.admin?
      i18n_t 'always_online'
    elsif object.bot?
      i18n_t 'always_online_bot'
    elsif Time.zone.now - 5.minutes <= exact_last_online_at || object.id == User::GUEST_ID
      i18n_t 'online'
    else
      i18n_t 'offline',
        time_ago: h.time_ago_in_words(exact_last_online_at),
        ago: (" #{i18n_t 'ago'}" if exact_last_online_at > 1.day.ago)
    end
  end

  def unread_messages_url
    if unread_messages > 0 || (unread_news == 0 && unread_notifications == 0)
      h.profile_dialogs_url object, subdomain: false
    elsif unread_news > 0
      h.index_profile_messages_url object, messages_type: :news, subdomain: false
    else
      h.index_profile_messages_url object, messages_type: :notifications, subdomain: false
    end
  end

  def avatar_url size, ignore_censored = false
    if !ignore_censored && censored_avatar?
      format(
        'https://www.gravatar.com/avatar/%s?s=%i&d=identicon',
        Digest::MD5.hexdigest('takandar+censored@gmail.com'),
        size
      )
    else
      # "https://www.gravatar.com/avatar/%s?s=%i&d=identicon" % [Digest::MD5.hexdigest(email.downcase), size]
      ImageUrlGenerator.instance.url object, "x#{size}".to_sym
    end
  end
end
