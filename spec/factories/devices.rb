# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :device do
    token { '11111111111111111111111111111111111111' }
    name { 'Nexus One' }
    platform { :ios }
    user { seed :user }
  end
end
