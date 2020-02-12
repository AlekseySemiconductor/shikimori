class Video < ApplicationRecord
  ALLOWED_HOSTINGS = %i[youtube vk rutube sibnet smotret_anime] # dailymotion

  belongs_to :anime, optional: true
  belongs_to :uploader, class_name: User.name

  enumerize :hosting,
    in: Types::Video::Hosting.values,
    predicates: true
  enumerize :kind,
    in: Types::Video::Kind.values,
    predicates: true

  validates :uploader_id, :url, :kind, presence: true
  validates_uniqueness_of :url,
    case_sensitive: true,
    scope: [:anime_id],
    conditions: -> { where.not state: :deleted }

  before_create :check_url
  before_create :check_hosting

  scope :youtube, -> { where hosting: :youtube }
  scope :ordered, -> {
    order(
      Arel.sql(
        <<~SQL.squish
          case kind
            #{kind.values.map.with_index { |v, index| "when '#{v}' then #{index}" }.join("\n")}
            else 99999999999
          end, id
        SQL
      )
    )
  }

  YOUTUBE_PARAM_REGEXP = /(?:&|\?)v=(.*?)(?:&|$)/
  VK_PARAM_REGEXP = %r{https?://vk.com/video-?(\d+)_(\d+)}

  state_machine :state, initial: :uploaded do
    state :uploaded
    state :confirmed
    state :deleted

    event :confirm do
      transition %i[uploaded deleted] => :confirmed
    end
    event :del do
      transition %i[uploaded confirmed] => :deleted
    end
  end

  def url= url
    return if url.blank?

    self[:url] = "https:#{Url.new(super).cut_www.without_protocol}"

    data = VideoExtractor.fetch self[:url]
    if data
      self.hosting = data.hosting
      self.image_url = data.image_url
      self.player_url = data.player_url
    end

    self[:url]
  end

  def camo_image_url
    if vk?
      UrlGenerator.instance.camo_url(
        Url.new(image_url).with_http.to_s,
        force_shikimori_one: true
      )
    else
      image_url
    end
  end

private

  def check_url
    return if hosting.present?

    errors.add(
      :url,
      I18n.t('activerecord.errors.models.videos.attributes.url.incorrect')
    )
    throw :abort
  end

  def check_hosting
    return if ALLOWED_HOSTINGS.include? hosting.to_sym

    errors.add(
      :url,
      I18n.t('activerecord.errors.models.videos.attributes.hosting.incorrect')
    )
    throw :abort
  end
end
