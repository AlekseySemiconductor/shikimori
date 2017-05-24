FactoryGirl.define do
  factory :version do
    item { build_stubbed :anime }
    user nil
    state :pending
    item_diff russian: ['a', 'b']

    trait :pending do
      state :pending
    end

    trait :accepted do
      state :accepted
    end

    trait :taken do
      state :taken
    end

    trait :rejected do
      state :rejected
    end

    trait :deleted do
      state :deleted
    end
  end

  factory :description_version, parent: :version, class: 'Versions::DescriptionVersion' do
  end

  factory :screenshots_version, parent: :version, class: 'Versions::ScreenshotsVersion' do
  end

  factory :video_version, parent: :version, class: 'Versions::VideoVersion' do
  end

  factory :genres_version, parent: :version, class: 'Versions::GenresVersion' do
  end

  factory :poster_version, parent: :version, class: 'Versions::PosterVersion' do
  end

  factory :collection_version, parent: :version, class: 'Versions::CollectionVersion' do
  end

  factory :version_anime_video, parent: :version do
    item_type AnimeVideo.name
    state :auto_accepted
  end
end
