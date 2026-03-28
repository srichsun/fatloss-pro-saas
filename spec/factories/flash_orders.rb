FactoryBot.define do
  factory :flash_order do
    flash_campaign { nil }
    email { "MyString" }
    name { "MyString" }
    phone { "MyString" }
    status { "MyString" }
  end
end
