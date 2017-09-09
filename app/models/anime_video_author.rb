class AnimeVideoAuthor < ApplicationRecord
  has_many :anime_videos, dependent: :restrict_with_exception

  boolean_attribute :verified

  validates :name, presence: true, uniqueness: true

  def name= value
    super self.class.fix_name(value)
  end

  def self.fix_name name
    name.to_s[0..254].strip
  end
end
