class Topics::Urls < ViewObjectBase
  pattr_initialize :view
  delegate :topic, :is_preview, to: :view

  # адрес заголовка топика
  def poster_url
    if is_preview
      topic_url
    else
      h.profile_url topic.user
    end
  end

  # адрес текста топика
  def body_url
    h.entry_body_url topic
  end

  def edit_url
    if topic.review_topic?
      h.send "edit_#{topic.linked.target_type.downcase}_review_url",
        topic.linked.target, topic.linked
    else
      h.edit_topic_url topic
    end
  end

  def destroy_url
    if topic.review_topic?
      h.send "#{topic.linked.target_type.downcase}_review_url",
        topic.linked.target, topic.linked
    else
      h.topic_path topic
    end
  end

  def subscribe_url
    h.subscribe_url type: topic.class.name, id: topic.id
  end

  def topic_url
    UrlGenerator.instance.topic_url topic
  end

  def ignore_url
    h.api_topic_ignores_url(topic_ignore: {
      topic_id: topic.id,
      user_id: h.current_user.id
    })
  end

  def unignore_url
    h.api_topic_ignore_url view.topic_ignore
  end
end
