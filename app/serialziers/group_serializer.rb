class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo

  def logo
    {
      original: object.logo.url(:original),
      main: object.logo.url(:main),
      x96: object.logo.url(:x96),
      x73: object.logo.url(:x73),
      x48: object.logo.url(:x48)
    }
  end
end
