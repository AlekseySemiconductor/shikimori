class Forum < ApplicationRecord
  has_many :topics, dependent: :destroy

  validates :permalink, presence: true

  # разделы, в которые можно создавать топики из интерфейса
  PUBLIC_SECTIONS = %w[animanga site games vn contests offtopic]
  VARIANTS = PUBLIC_SECTIONS + %w[
    clubs my_clubs reviews news collections cosplay
  ]

  ANIME_NEWS_ID = 1
  SITE_ID = 4
  OFFTOPIC_ID = 8
  CLUBS_ID = 10
  CONTESTS_ID = 13
  COLLECTION_ID = 14
  COSPLAY_ID = 15
  NEWS_ID = 20

  NEWS_FORUM = FakeForum.new 'news', 'Лента новостей', 'News feed'
  UPDATES_FORUM = FakeForum.new 'updates', 'Обновления аниме', 'Anime updates'
  MY_CLUBS_FORUM = FakeForum.new 'my_clubs', 'Мои клубы', 'My clubs'

  def to_param
    permalink
  end

  def name
    I18n.russian? ? name_ru : name_en
  end

  class << self
    def public
      cached
        .select { |v| PUBLIC_SECTIONS.include? v.permalink }
        .sort_by { |v| PUBLIC_SECTIONS.index v.permalink }
    end

    def visible
      cached.select(&:is_visible).sort_by(&:position)
    end

    def find_by_permalink permalink
      (cached + [NEWS_FORUM, UPDATES_FORUM, MY_CLUBS_FORUM]).find do |forum|
        forum.permalink == permalink
      end
    end

    def cached
      @cached ||= all.to_a.sort_by(&:position)
    end
  end
end
