class CommentDecorator < BaseDecorator
  instance_cache :html_body

  def html_body
    if persisted?
      Rails.cache.fetch cache_key do
        object.html_body
      end
    else
      object.html_body
    end
  end

  def broadcast?
    object.body.include? Comment::Broadcast::BB_CODE
  end

private

  def cache_key
    CacheHelper.keys(
      object,
      :body,
      :v6
    )
  end
end
