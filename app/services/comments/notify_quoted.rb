class Comments::NotifyQuoted
  method_object %i[old_body new_body comment user]

  ANTISPAM_LIMIT = 15

  # rubocop:disable AbcSize
  def call
    Message.wo_antispam do
      Message.import messages_to_create
    end
    messages_to_destroy.each(&:destroy)

    reply new_quoted.comments - old_quoted.comments, :append
    reply old_quoted.comments - new_quoted.comments, :remove
  end
  # rubocop:enable AbcSize

private

  def reply comments, action
    comments.each do |comment|
      Comments::Reply.new(comment).send :"#{action}_reply", @comment
    end
  end

  def messages_to_create
    users_to_notify.map do |user|
      Message.new(
        to: user,
        from: @user,
        kind: MessageType::QuotedByUser,
        linked: @comment
      )
    end
  end

  # rubocop:disable AbcSize
  def users_to_notify
    users = (new_quoted.users - old_quoted.users)
      .reject { |user| user.id == @user.id }
    return [] if users.none?

    ignores = Ignore.where(user_id: users.map(&:id), target: @user)
    notifications = notifications_scope(users).to_a

    users.select do |user|
      ignores.none? { |ignore| ignore.user_id == user.id } &&
        notifications.none? { |message| message.to_id == user.id }
    end
  end
  # rubocop:enable AbcSize

  def messages_to_destroy
    users = old_quoted.users - new_quoted.users
    return [] if users.none?

    notifications_scope users
  end

  def notifications_scope users
    Message.where(
      to_id: users.map(&:id),
      from: @user,
      kind: MessageType::QuotedByUser,
      linked: @comment
    )
  end

  def old_quoted
    @old_quoted ||= extract_quoted_service.call(
      (BbCodes::UserMention.call(@old_body) if @old_body)
    )
  end

  def new_quoted
    @new_quoted ||= extract_quoted_service.call(
      (BbCodes::UserMention.call(@new_body) if @new_body)
    )
  end

  def extract_quoted_service
    @extract_quoted_service ||= Comments::ExtractQuoted.new
  end
end
