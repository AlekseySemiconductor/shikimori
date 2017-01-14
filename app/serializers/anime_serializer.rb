class AnimeSerializer < ActiveModel::Serializer
  attributes :id, :name, :russian, :image, :url, :kind,
    :status, :episodes, :episodes_aired, :aired_on, :released_on

  def image
    {
      original: object.image.url(:original),
      preview: object.image.url(:preview),
      x96: object.image.url(:x96),
      x48: object.image.url(:x48)
    }
  end

  def url
    UrlGenerator.instance.anime_path object
  end
end
