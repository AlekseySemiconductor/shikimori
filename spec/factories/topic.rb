FactoryGirl.define do
  factory :topic do
    user { seed :user }
    forum { seed :offtopic_forum }
    sequence(:title) { |n| "topic_#{n}" }
    sequence(:body) { |n| "topic_text_#{n}" }

    locale 'ru'

    factory :anime_topic, class: 'Topics::EntryTopics::AnimeTopic' do
      type 'Topics::EntryTopics::AnimeTopic'
      forum { seed :animanga_forum }
      generated true
    end

    factory :manga_topic, class: 'Topics::EntryTopics::MangaTopic' do
      type 'Topics::EntryTopics::MangaTopic'
      forum { seed :animanga_forum }
      generated true
    end

    factory :character_topic, class: 'Topics::EntryTopics::CharacterTopic' do
      type 'Topics::EntryTopics::CharacterTopic'
      forum { seed :animanga_forum }
      generated true
    end

    factory :person_topic, class: 'Topics::EntryTopics::PersonTopic' do
      type 'Topics::EntryTopics::PersonTopic'
      forum { seed :animanga_forum }
      generated true
    end

    factory :review_topic, class: 'Topics::EntryTopics::ReviewTopic' do
      type 'Topics::EntryTopics::ReviewTopic'
      forum { seed :reviews_forum }
      generated true
    end

    factory :cosplay_gallery_topic, class: 'Topics::EntryTopics::CosplayGalleryTopic' do
      type 'Topics::EntryTopics::CosplayGalleryTopic'
      generated true
    end

    factory :contest_topic, class: 'Topics::EntryTopics::ContestTopic' do
      type 'Topics::EntryTopics::ContestTopic'
      generated true
    end

    factory :club_topic, class: 'Topics::EntryTopics::ClubTopic' do
      type 'Topics::EntryTopics::ClubTopic'
      generated true
    end

    factory :news_topic, class: 'Topics::NewsTopic' do
      type 'Topics::NewsTopic'
      forum { seed :animanga_forum }

      trait :anime_anons do
        linked { create :anime }
        action :anons
        generated true
      end
    end

    after :build do |topic|
      topic.class.skip_callback :create, :before, :check_antispam
    end

    trait :offtopic do
      title 'offtopic'
      body 'offtopic'
      created_at { 1.day.ago }
      updated_at { 1.day.ago }
      forum { seed :offtopic_forum }
    end
    trait :rules do
      id StickyTopicView::TOPIC_IDS[:site_rules][:ru]
      title 'rules'
      body 'rules'
      created_at { 2.days.ago }
      updated_at { 2.days.ago }
      forum { seed :offtopic_forum }
    end
    trait :faq do
      id StickyTopicView::TOPIC_IDS[:faq][:ru]
      title 'faq'
      body 'faq'
      created_at { 3.days.ago }
      updated_at { 3.days.ago }
      forum { seed :offtopic_forum }
    end

    factory :offtopic_topic, traits: [:offtopic]
    factory :rules_topic, traits: [:rules]
    factory :faq_topic, traits: [:faq]
  end
end
