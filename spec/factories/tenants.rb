FactoryBot.define do
  factory :tenant do
    sequence(:name) { |n| "Storefront #{n}" }
    sequence(:subdomain) { |n| "store-#{n}" }
  end
end
