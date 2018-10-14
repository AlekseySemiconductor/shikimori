FactoryBot.define do
  factory :collection do
    sequence(:name) { |n| "Collection #{n}" }
    user { seed :user }
    kind { :anime }
    state { :unpublished }
    text { '' }
    locale { :ru }

    Types::Collection::State.values.each { |value| trait(value) { state { value } } }
    Types::Collection::Kind.values.each { |value| trait(value) { kind { value } } }

    after :build do |model|
      stub_method model, :antispam_checks
    end

    trait(:pending) { moderation_state { :pending } }
    trait(:accepted) { moderation_state { :accepted } }
    trait(:rejected) { moderation_state { :rejected } }

    trait :with_topics do
      after(:create) { |model| model.generate_topics model.locale }
    end
  end
end
