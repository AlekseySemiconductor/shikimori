FactoryGirl.define do
  factory :poll do
    user { seed :user }
    state :pending
    name 'new poll'
    text 'poll text'

    Poll.state_machine.states.map(&:value).each do |poll_state|
      trait(poll_state.to_sym) { state poll_state }
    end

    trait :with_variants do
      after :build do |model|
        FactoryGirl.create :poll_variant, poll: model
        FactoryGirl.create :poll_variant, poll: model
      end
    end
  end
end
