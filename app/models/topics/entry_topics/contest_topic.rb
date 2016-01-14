class Topics::EntryTopics::ContestTopic < Topics::EntryTopic
  def text
    "Топик [contest=#{linked.id}]опроса[/contest].
    Статус: #{linked.decorate.status}"
  end

  def title
    "Опрос \"#{linked.title}\""
  end
end
