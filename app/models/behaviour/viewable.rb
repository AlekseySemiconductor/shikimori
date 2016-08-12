# for entries and comments
module Viewable
  extend ActiveSupport::Concern

  INTERVAL = 1.week

  included do |klass|
    klass_name = (self.respond_to?(:base_class) ? base_class.name : name)
    view_klass = Object.const_get(klass_name + 'View')

    # чёртов гем ломает присвоение ассоциаций в FactoryGirl, и я не знаю, как это быстро починить другим способом
    if Rails.env.test?
      has_many :views, class_name: view_klass.name
    else
      has_many :views, class_name: view_klass.name, dependent: :delete_all
    end

    # для автора сразу же создаётся view
    after_create lambda {
      view_klass.create! user_id: self.user_id, klass_name.downcase => self
    }

    klass.const_set(
      'VIEWED_JOINS_SELECT',
      "coalesce(jv.#{name.downcase}_id, 0) > 0 as viewed"
    )

    scope :with_viewed, lambda { |user|
      if user
        joins("left join #{view_klass.table_name} jv on jv.#{name.downcase}_id=#{table_name}.id and jv.user_id='#{user.id}'")
          .select("#{table_name}.*, coalesce(jv.#{name.downcase}_id, 0) > 0 as viewed")
      else
        select("#{table_name}.*, #{klass::VIEWED_JOINS_SELECT}")
      end
    }
  end

  def viewed?
    self[:viewed].nil? || (created_at + INTERVAL < Time.zone.today) ? true : self[:viewed]
  end
end
