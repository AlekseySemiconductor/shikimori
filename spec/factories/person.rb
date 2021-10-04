FactoryBot.define do
  factory :person do
    sequence(:name) { |n| "person_#{n}" }
    sequence(:russian) { |n| "человек_#{n}" }
    desynced { [] }
    imported_at { nil }

    after :build do |model|
      stub_method model, :touch_related
    end

    trait :anime do |_person|
      after :create do |person|
        create :anime, person_roles: [
          create(:person_role, role: 'Producer', person: person)
        ]
      end
    end

    trait :with_topics do
      after(:create) { |model| model.generate_topics :ru }
    end
  end
end
