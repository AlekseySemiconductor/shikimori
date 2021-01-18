class Version < ApplicationRecord
  include AntispamConcern

  antispam(
    per_day: 25,
    disable_if: -> { item_diff['description_ru'].present? || user.staff? },
    scope: -> { where "(item_diff->>'description_ru') is null" },
    user_id_key: :user_id
  )
  antispam(
    per_day: 10,
    disable_if: -> { item_diff['description_ru'].blank? || user.staff? },
    scope: -> { where "(item_diff->>'description_ru') is not null" },
    user_id_key: :user_id
  )

  belongs_to :user,
    touch: Rails.env.test? ? false : :activity_at
  belongs_to :moderator, class_name: 'User', optional: true
  # optional item becase it can be deleted later and we don't need this version to fail on validation
  belongs_to :item, polymorphic: true, touch: true, optional: true
  belongs_to :associated, polymorphic: true, touch: true, optional: true

  validates :item_diff, presence: true
  validates :item, presence: true, if: :new_record?

  scope :pending, -> { where state: :pending }

  state_machine :state, initial: :pending do
    state :accepted
    state :auto_accepted
    state :rejected

    state :taken
    state :deleted

    event(:accept) { transition pending: :accepted }
    event(:auto_accept) { transition pending: :auto_accepted, unless: :takeable? }
    event(:take) { transition pending: :taken }
    event(:reject) { transition %i[pending auto_accepted] => :rejected }
    event(:to_deleted) { transition pending: :deleted, if: :deleteable? }

    event(:accept_taken) { transition taken: :accepted, if: :takeable? }
    event(:take_accepted) { transition accepted: :taken, if: :takeable? }

    before_transition(
      pending: %i[accepted auto_accepted taken]
    ) do |version, transition|
      version.apply_changes || raise(
        StateMachine::InvalidTransition.new(
          version,
          transition.machine,
          transition.event
        )
      )
      version.update moderator: version.user if transition.event
    end
    before_transition pending: %i[auto_accepted] do |version, _transition|
      version.moderator = version.user
    end

    before_transition pending: :rejected do |version, transition|
      version.reject_changes || raise(
        StateMachine::InvalidTransition.new(
          version,
          transition.machine,
          transition.event
        )
      )
    end

    before_transition auto_accepted: :rejected do |version, transition|
      version.rollback_changes || raise(
        StateMachine::InvalidTransition.new(
          version,
          transition.machine,
          transition.event
        )
      )
    end

    before_transition(
      %i[pending auto_accepted] => %i[rejected deleted]
    ) do |version, transition|
      version.update moderator: transition.args.first if transition.args.first
    end

    before_transition(
      %i[pending auto_accepted] => %i[accepted taken rejected deleted]
    ) do |version, transition|
      version.update moderator: transition.args.first if transition.args.first
    end

    after_transition pending: %i[accepted taken] do |version, _transition|
      version.fix_state if version.respond_to? :fix_state
      version.notify_acceptance
    end

    after_transition(
      %i[pending auto_accepted] => %i[rejected]
    ) do |version, transition|
      version.notify_rejection transition.args.second
    end

    after_transition pending: :deleted do |version, _transition|
      version.cleanup if version.respond_to? :cleanup
    end
  end

  def apply_changes
    item.class.transaction do
      item_diff
        .sort_by { |(field, _changes)| field == 'desynced' ? 1 : 0 }
        .each { |(field, changes)| apply_change field, changes }
    end
  end

  def reject_changes
    true
  end

  def rollback_changes
    item.update item_diff.transform_values(&:first)
  end

  def current_value field
    item.send field
  rescue NoMethodError
  end

  def notify_acceptance
    unless user_id == moderator_id
      Message.create_wo_antispam!(
        from_id: moderator_id,
        to_id: user_id,
        kind: MessageType::VERSION_ACCEPTED,
        linked: self
      )
    end
  end

  def notify_rejection reason
    unless user_id == moderator_id
      Message.create_wo_antispam!(
        from_id: moderator_id,
        to_id: user_id,
        kind: MessageType::VERSION_REJECTED,
        linked: self,
        body: reason
      )
    end
  end

  def takeable?
    false
  end

  def deleteable?
    true
  end

private

  def apply_change field, changes
    changes[0] = current_value field
    item.send "#{field}=", truncate_value(field, changes.second)

    add_desynced field

    item.save && save
  end

  def add_desynced field
    if item.respond_to?(:desynced) && item.class::DESYNCABLE.include?(field)
      item.desynced << field unless item.desynced.include?(field)
    end
  end

  def truncate_value field, value
    if item.class.columns_hash[field]&.limit && value.is_a?(String)
      value[0..item.class.columns_hash[field].limit - 1]
    else
      value
    end
  end
end
