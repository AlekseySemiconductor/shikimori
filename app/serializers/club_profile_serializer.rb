class ClubProfileSerializer < ClubSerializer
  attributes :description, :description_html, :mangas, :characters, :thread_id,
    :topic_id, :user_role, :style_id
  has_many :members
  has_many :animes
  has_many :mangas
  has_many :characters
  has_many :images

  def description
    object.description.text
  end

  # TODO: deprecated
  def thread_id
    object.maybe_topic(scope.locale_from_host).id
  end

  def topic_id
    object.maybe_topic(scope.locale_from_host).id
  end
end
