FactoryGirl.define do
  factory :anime_video do
    sequence(:url) { |n| "http://vk.com/video_ext.php?oid=-49842926&id=171419019&hash=5ca0a0daa459cd16#{n}" }
    source 'http://source.com'
    kind AnimeVideo.kind.values.first
    anime { seed :anime }
    episode 1
    author nil
    state 'working'

    after :build do |model|
      stub_method model, :create_episode_notificaiton
    end

    AnimeVideo.kind.values.each do |video_kind|
      trait(video_kind.to_sym) { kind video_kind }
    end

    AnimeVideo.language.values.each do |video_language|
      trait(video_language.to_sym) { language video_language }
    end

    AnimeVideo.state_machine.states.map(&:value).each do |video_state|
      trait(video_state.to_sym) { state video_state }
    end

    trait :with_notification do
      after(:build) { |model| unstub_method model, :create_episode_notificaiton }
    end
  end
end
