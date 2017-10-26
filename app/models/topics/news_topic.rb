class Topics::NewsTopic < Topic
  enumerize :action,
    in: Types::Topic::NewsTopic::Action.values,
    predicates: true

  def title
    return super unless generated?

    if episode?
      "#{action_text} #{value}".capitalize
    else
      action_text.capitalize
    end
  end

  # для message
  def full_title
    return title unless generated?

    BbCodes::Text.call(I18n.t(
      "topics/news_topic.full_title.#{linked_type.underscore}",
      action_name: title,
      action_name_lower: title.downcase,
      id: linked_id,
      type: linked_type.underscore
    )).gsub(/<.*?>/, '')
  end
end
