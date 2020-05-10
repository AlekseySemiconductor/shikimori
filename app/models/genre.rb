class Genre < ApplicationRecord
  include Translation

  has_and_belongs_to_many :animes
  has_and_belongs_to_many :mangas

  validates :name, presence: true

  enumerize :kind, in: %i[anime manga], predicates: true

  DOUJINSHI_IDS = [61]

  HENTAI_IDS = [12, 59] + DOUJINSHI_IDS
  YAOI_IDS = [33, 65]
  YURI_IDS = [34, 75]

  SHOUNEN_AI_IDS = [28, 55]
  SHOUJO_AI_IDS = [26, 73]

  CENSORED_IDS = HENTAI_IDS + YAOI_IDS + YURI_IDS

  MAIN_GENRES = [
    'Seinen',
    'Josei',
    'Yaoi',
    'Hentai',
    'Action',
    'Comedy',
    'Drama',
    'Romance',
    'Slice of Life',
    'School',
    'Samurai',
    'Vampire',
    'Sci-Fi',
    'Mystery',
    'Mecha',
    'Yuri',
    'Shoujo Ai',
    'Shounen Ai',
    'Shoujo',
    'Shounen'
  ]

  LONG_NAME_GENRES = [
    'Slice of Life',
    'Martial Arts',
    'Supernatural',
    'Psychological'
  ]

  MERGED = {}

  def main?
    MAIN_GENRES.include?(english)
  end

  def title ru_case: :subjective, user: nil
    key = english.parameterize.underscore
    name = UsersHelper.localized_name self, user
    kind = self.kind.capitalize.constantize.model_name.human

    i18n_t(
      "title.#{ru_case}.#{self.kind}.#{key}",
      kind: kind,
      default: i18n_t('default_title', kind: kind, name: name)
    ).capitalize
  end

  def english
    self[:name]
  end

  def to_param
    "#{id}-#{english.tr ' ', '-'}"
  end

  def censored?
    CENSORED_IDS.include? id
  end
end
