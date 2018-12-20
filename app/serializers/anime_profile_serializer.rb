class AnimeProfileSerializer < AnimeSerializer
  attributes :rating, :english, :japanese, :synonyms, :license_name_ru, :kind, :aired_on,
    :released_on, :episodes, :episodes_aired, :duration, :score, :description,
    :description_html, :description_source, :franchise,
    :favoured, :anons, :ongoing, :thread_id, :topic_id,
    :myanimelist_id,
    :rates_scores_stats, :rates_statuses_stats, :updated_at, :next_episode_at

  has_many :genres
  has_many :studios
  has_many :videos
  has_many :screenshots

  has_one :user_rate

  def description
    object.description.text
  end

  def user_rate
    UserRateFullSerializer.new(object.current_rate) if object.current_rate
  end

  # TODO: deprecated
  def thread_id
    object.maybe_topic(scope.locale_from_host).id
  end

  def topic_id
    object.maybe_topic(scope.locale_from_host).id
  end

  def myanimelist_id
    object.id
  end

  def english
    [object.english]
  end

  def japanese
    [object.japanese]
  end

  def description
    object.description.text
  end

  def description_html
    object.description_html.gsub(%r{(?<!:)//(?=\w)}, 'http://')
  end

  def description_source
    object.description.source
  end

  def videos
    object.videos 2
  end

  def screenshots
    object.screenshots 2
  end

  def favoured
    object.favoured?
  end

  def ongoing
    object.ongoing?
  end

  def anons
    object.anons?
  end
end
