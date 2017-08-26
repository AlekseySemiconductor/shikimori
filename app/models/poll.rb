class Poll < ApplicationRecord
  acts_as_votable

  include Translation

  belongs_to :user
  has_many :variants, -> { order :id },
    class_name: PollVariant.name,
    inverse_of: :poll,
    dependent: :destroy

  validates :user, presence: true

  state_machine :state, initial: :pending do
    state :pending
    state :started
    state :stopped

    event(:start) do
      transition pending: :started, if: lambda { |poll|
        poll.persisted? && poll.variants.size > 1
      }
    end
    event(:stop) { transition started: :stopped }
  end

  accepts_nested_attributes_for :variants

  def name
    return super if super.present? || new_record?

    i18n_t 'name', id: id
  end

  def bb_code
    "[poll=#{id}]"
  end

  def text_html
    BbCodeFormatter.instance.format_comment text
  end
end
