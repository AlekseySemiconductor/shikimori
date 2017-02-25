class PersonProfileSerializer < PersonSerializer
  attributes :japanese, :job_title, :birthday, :website, :groupped_roles,
    :roles, :works, :thread_id, :topic_id,
    :person_favoured, :producer, :producer_favoured,
    :mangaka, :mangaka_favoured, :seyu, :seyu_favoured,
    :updated_at

  def roles
    []
  end

  def works
    object.works.map do |work|
      {
        anime: work.object.kind_of?(Anime) ? AnimeSerializer.new(work) : nil,
        manga: work.object.kind_of?(Manga) ? MangaSerializer.new(work) : nil,
        role: work.formatted_role
      }
    end
  end

  # TODO: deprecated
  def thread_id
    object.maybe_topic(scope.locale_from_host).id
  end

  def topic_id
    object.maybe_topic(scope.locale_from_host).id
  end

  def person_favoured
    object.person_favoured?
  end

  def producer
    object.producer?
  end

  def producer_favoured
    object.producer_favoured?
  end

  def mangaka
    object.mangaka?
  end

  def mangaka_favoured
    object.mangaka_favoured?
  end

  def seyu
    object.seyu?
  end

  def seyu_favoured
    object.seyu_favoured?
  end
end
