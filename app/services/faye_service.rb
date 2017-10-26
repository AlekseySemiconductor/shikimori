# сервис через который должны создаваться/изменяться/удаляться все объекты,
# отображаемые на форуме и имеющие realtime обновления
class FayeService
  pattr_initialize :actor, :publisher_faye_id

  def create trackable
    was_persisted = trackable.persisted?

    if trackable.save
      publisher.publish trackable, was_persisted ? :updated : :created
      true
    else
      false
    end
  end

  def create! trackable
    was_persisted = trackable.persisted?

    trackable.save!
    publisher.publish trackable, was_persisted ? :updated : :created
  end

  def update trackable, params
    if trackable.update params
      publisher.publish trackable, :updated
      true
    else
      false
    end
  end

  def destroy trackable
    if trackable.is_a? Message
      trackable.delete_by @actor
    else
      publisher.publish trackable, :deleted
      trackable.destroy
    end
  end

  def offtopic comment, flag
    ids = comment.mark_offtopic flag
    publisher.publish_marks ids, 'offtopic', flag
    ids
  end

  def summary comment, flag
    ids = comment.mark_summary flag
    publisher.publish_marks ids, 'summary', flag
    ids
  end

  # уведомление о том, что у комментария изменился блок с ответами
  def set_replies comment
    replies_text = if comment.body =~ BbCodes::Tags::RepliesTag::REGEXP
      $LAST_MATCH_INFO[:tag]
    else
      ''
    end
    replies_html = BbCode.instance.format_comment replies_text

    publisher.publish_replies comment, replies_html
  end

private

  def publisher
    FayePublisher.new @actor, @publisher_faye_id
  end
end
