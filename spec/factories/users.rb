FactoryBot.define do
  factory :user do
    association :tenant
    sequence(:email) { |n| "owner#{n}@test.com" }
    name { "Owner" }
    password { "password" }
    password_confirmation { "password" }
  end
end
