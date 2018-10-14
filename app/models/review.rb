# frozen_string_literal: true

class Review < ApplicationRecord
  include AntispamConcern
  include Moderatable
  include TopicsConcern
  include ModeratableConcern

  antispam(
    interval: 15.minutes,
    per_day: 3,
    user_id_key: :user_id
  )

  acts_as_votable cacheable_strategy: :update_columns

  MINIMUM_LENGTH = 3000

  belongs_to :target, polymorphic: true, touch: true
  belongs_to :user

  validates :user, :target, presence: true
  validates :text,
    length: {
      minimum: MINIMUM_LENGTH,
      too_short: "too short (#{MINIMUM_LENGTH} symbols minimum)"
    },
    if: -> { changes['text'] }
  validates :locale, presence: true

  enumerize :locale, in: %i[ru en], predicates: { prefix: true }

  def topic_user
    user
  end

  # хз что это за хрень и почему ReviewComment.first.linked.target
  # возвращает сам обзор. я так и не понял
  def entry
    @entry ||= target_type.constantize.find(target_id)
  end

  def body
    text
  end
end
