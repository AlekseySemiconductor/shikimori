FactoryBot.define do
  factory :message do
    from { seed :user }
    to { seed :user }

    read { false }

    after :build do |model|
      stub_method model, :antispam_checks
      stub_method model, :send_push_notifications
      stub_method model, :check_spam_abuse
    end

    kind { MessageType::Private }
    body { 'test' }

    trait :private do
      kind { MessageType::Private }
    end

    trait :notification do
      kind { MessageType::Notification }
    end

    trait :profile_commented do
      kind { MessageType::ProfileCommented }
    end

    trait :news do
      kind { MessageType::SiteNews }
    end

    trait :with_antispam do
      after(:build) { |model| unstub_method model, :antispam_checks }
    end
    trait :with_push_notifications do
      after(:build) { |model| unstub_method model, :send_push_notifications }
    end
    trait :with_check_spam_abuse do
      after(:build) { |model| unstub_method model, :check_spam_abuse }
    end
  end
end
