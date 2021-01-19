class MessagesService
  pattr_initialize :user

  def read_by is_read:, kind: nil, type: nil, ids: nil
    raise ArgumentError unless kind || type || ids

    scope = Message
      .where(to: user)
      .where(read: !is_read)

    scope.where! kind: kind if kind
    scope.where! kind: kinds_by_type(type) if type
    scope.where! id: ids if ids

    scope.update_all read: is_read
    user.touch
  end

  def delete_by kind: nil, type: nil
    raise ArgumentError unless kind || type || ids

    scope = Message.where(to: user)

    scope.where! kind: kind if kind
    scope.where! kind: kinds_by_type(type) if type

    scope.delete_all
    user.touch
  end

private

  def kinds_by_type type
    MessagesQuery.new(user, type).where_by_type[:kind]
  end
end
