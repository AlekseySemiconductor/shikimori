class Forums::Form < ViewObjectBase
  instance_cache :news_rules_topic

  RULES_TOPIC_ID = 193484

  def news_rules_topic
    Topic.find RULES_TOPIC_ID
  end

  def news_rules_text
    BbCode.instance.format_comment(
      news_rules_topic.body.gsub(/\[hr\].*/mix, '').strip
    )
  end
end
