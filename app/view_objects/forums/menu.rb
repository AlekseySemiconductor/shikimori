class Forums::Menu < ViewObjectBase
  pattr_initialize :forum, :linked
  instance_cache :club_topics, :contests, :reviews

  def club_topics
    Topics::EntryTopics::ClubTopic
      .includes(:linked)
      .where(locale: h.locale_from_domain)
      .order(updated_at: :desc)
      .limit(3)
  end

  def contests
    Contest.current
  end

  def changeable_forums?
    h.user_signed_in? && h.params[:action] == 'index' && h.params[:forum].nil?
  end

  def forums
    Forums::List.new
  end

  def reviews
    @reviews ||= Review
      .where('created_at >= ?',  2.weeks.ago)
      .where(locale: h.locale_from_domain)
      .visible
      .includes(:user, :target, topics: [:forum])
      .order(created_at: :desc)
      .limit(3)
  end

  def sticky_topics
    [
      StickyTopic.new(
        url: '/s/79042-Pravila-sayta',
        title: "#{I18n.t 'site_rules'}",
        description: 'Что не стоит делать на сайте'
      ),
      StickyTopic.new(
        url: '/s/85018-FAQ-Chasto-zadavaemye-voprosy',
        title: 'FAQ',
        description: "#{I18n.t 'faq'}"
      ),
      StickyTopic.new(
        url: '/s/103553-Opisaniya-zhanrov',
        title: 'Описания жанров',
        description: 'Для желающих помочь сайту'
      ),
      StickyTopic.new(
        url: '/s/10586-Pozhelaniya-po-saytu',
        title: 'Идеи и предложения',
        description: 'Было бы неплохо реализовать это...'
      ),
      StickyTopic.new(
        url: '/s/102-Tema-ob-oshibkah',
        title: 'Ошибки',
        description: 'Топик о любых проблемах на сайте'
      )
    ]
  end

  def new_topic_url
    h.new_topic_url(
      forum: forum,
      linked_id: h.params[:linked_id],
      linked_type: h.params[:linked_type],
      'topic[user_id]' => h.current_user.id,
      'topic[forum_id]' => forum ? forum.id : nil,
      'topic[linked_id]' => linked ? linked.id : nil,
      'topic[linked_type]' => linked ? linked.class.name : nil
    )
  end
end
