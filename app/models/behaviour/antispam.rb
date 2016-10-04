module Antispam
  extend ActiveSupport::Concern

  included do
    before_create :check_antispam
    @antispam = true
  end

  module ClassMethods
    attr_accessor :antispam

    def wo_antispam
      @antispam = false
      val = yield
      @antispam = true
      val
    end

    def create_wo_antispam! options
      @antispam = false
      val = create!(options)
      @antispam = true
      val
    end

    def with_antispam?
      @antispam
    end
  end

  def with_antispam?
    self.class.with_antispam?
  end

  def check_antispam
    return if id # если id есть, значит это редактирование
    return unless with_antispam?
    return if User::ADMINS.include?(user_id)

    prior = self
      .class
      .where(user_id: user_id)
      .order(id: :desc)
      .first

    return unless prior
    return if BotsService.posters.include?(self.user_id)

    if prior && DateTime.now.to_i - prior.created_at.to_i < 3
      interval = 3 - (DateTime.now.to_i - prior.created_at.to_i)
      errors[:base] = 'Защита от спама. Попробуйте снова через %d %s.' % [interval, Russian.p(interval, 'секунду', 'секунды', 'секунд')]
      return false
    end
  end
end
