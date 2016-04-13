class UserHistoryView < ViewObjectBase
  pattr_initialize :user
  instance_cache :query

  LIMIT = 90

  def page
    (h.params[:page] || 1).to_i
  end

  def collection
    query[0]
  end

  def add_postloader?
    query[1]
  end

private

  def query
    Rails.cache.fetch [:history, user, page] do
      UserHistoryQuery.new(user).postload(page, LIMIT)
    end
  end
end
