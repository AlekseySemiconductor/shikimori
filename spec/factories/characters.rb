FactoryGirl.define do
  factory :character do
    sequence(:name) { |n| "character_#{n}" }
    sequence(:russian) { |n| "персонаж_#{n}" }
    description_ru ''
    description_en ''

    trait :anime do
      after :create do |character|
        FactoryGirl.create :anime, characters: [character]
      end
    end

    trait :with_topics do
      after(:create) { |character| character.generate_topics :en }
    end
  end
end
