FactoryBot.define do
  factory :manga do
    sequence(:name) { |n| "manga_#{n}" }
    sequence(:ranked)
    sequence(:russian) { |n| "манга_#{n}" }
    description_ru ''
    description_en ''
    score 1
    kind :manga
    type { Manga.name }

    factory :ranobe, class: 'Ranobe' do
      sequence(:name) { |n| "ranobe_#{n}" }
      sequence(:russian) { |n| "ранобэ_#{n}" }
      type Ranobe.name
      kind Ranobe::KIND
    end

    trait :with_mal_id do
      mal_id 1
    end

    after :build do |model|
      stub_method model, :generate_name_matches

      stub_method model, :touch_related
    end

    trait :with_topics do
      after(:create) { |model| model.generate_topics :ru }
    end

    Manga.kind.values.each do |kind_type|
      trait kind_type do
        kind kind_type
      end
    end
  end
end
