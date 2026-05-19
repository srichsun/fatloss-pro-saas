FactoryBot.define do
  factory :flash_order do
    association :flash_campaign
    name { "Fan One" }
    sequence(:email) { |n| "fan#{n}@test.com" }
    phone { "0900000000" }
    status { "pending" }
  end
end
