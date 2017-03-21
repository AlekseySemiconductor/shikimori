class Forums::List < ViewObjectBase
  include Enumerable
  instance_cache :decorated_forums

  pattr_initialize [:with_forum_size]

  def each
    cached_forums.each { |forum| yield forum }
  end

private

  def cached_forums
    return decorated_forums unless @with_forum_size
    Rails.cache.fetch([:forums, :v3, Topic.last&.id], expires_in: 2.weeks) do
      decorated_forums
    end
  end

  def decorated_forums
    visible_forums + static_forums
  end

  def visible_forums
    Forum.visible.map { |forum| decorate forum, false }
  end

  def static_forums
    [
      decorate(Forum::NEWS_FORUM, true),
      decorate(Forum.find_by_permalink('reviews'), true),
      decorate(Forum.find_by_permalink('contests'), true),
      decorate(Forum::MY_CLUBS_FORUM, true),
      decorate(Forum.find_by_permalink('clubs'), true)
    ]
  end

  def decorate forum, is_special
    size = is_special || !@with_forum_size ? nil : forum_size(forum)
    ForumForList.new forum, is_special, size
  end

  def forum_size forum
    Topics::Query.fetch(current_user, h.locale_from_host)
      .by_forum(forum, current_user, censored_forbidden?)
      .where('generated = false or (generated = true and comments_count > 0)')
      .size
  end

  def current_user
    h.current_user
  rescue NoMethodError
    nil
  end

  def censored_forbidden?
    h.respond_to?(:censored_forbidden?) ? h.censored_forbidden? : false
  end
end
