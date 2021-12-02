class AbuseRequestsService
  SUMMARY_TIMEOUT = 5.minutes
  OFFTOPIC_TIMEOUT = 5.minutes

  pattr_initialize %i[comment topic review reporter!]

  def offtopic faye_token
    raise CanCan::AccessDenied if @comment.nil?

    create_abuse_request :offtopic, !@comment.offtopic?, nil

    if allowed_offtopic_change?
      abuse_request = find_abuse_request :offtopic, !@comment.offtopic?
      abuse_request&.take! @reporter, faye_token
      @comment&.reload
      abuse_request&.affected_ids || []
    else
      []
    end
  end

  def summary faye_token
    raise CanCan::AccessDenied if @comment.nil?

    create_abuse_request :summary, !@comment.summary?, nil

    if allowed_summary_change?
      abuse_request = find_abuse_request :summary, !@comment.summary?
      abuse_request&.take! @reporter, faye_token
      @comment&.reload
      abuse_request&.affected_ids || []
    else
      []
    end
  end

  def abuse reason
    create_abuse_request :abuse, true, reason
  end

  def spoiler reason
    create_abuse_request :spoiler, true, reason
  end

private

  def find_abuse_request kind, value
    AbuseRequest.find_by(
      comment_id: @comment&.id,
      review_id: @review&.id,
      topic_id: @topic&.id,
      kind: kind,
      value: value,
      state: 'pending'
    )
  end

  def create_abuse_request kind, value, reason
    AbuseRequest.create!(
      comment_id: @comment&.id,
      review_id: @review&.id,
      topic_id: @topic&.id,
      user_id: reporter.id,
      kind: kind,
      value: value,
      state: 'pending',
      reason: reason
    )

    []
  rescue ActiveRecord::RecordNotUnique
    []
  end

  def allowed_summary_change?
    reporter.forum_moderator? || reporter.admin? ||
      (@comment && @comment.user_id == reporter.id &&
      @comment.created_at > SUMMARY_TIMEOUT.ago)
  end

  def allowed_offtopic_change?
    reporter.forum_moderator? || reporter.admin? ||
      (@comment && @comment.user_id == reporter.id &&
      @comment.created_at > OFFTOPIC_TIMEOUT.ago)
  end
end
