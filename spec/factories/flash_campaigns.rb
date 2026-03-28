FactoryBot.define do
  factory :flash_campaign do
    title { "MyString" }
    price { 1 }
    total_stock { 1 }
    remaining_stock { 1 }
    expired_at { "2026-03-28 14:40:42" }
    influencer_name { "MyString" }
  end
end
