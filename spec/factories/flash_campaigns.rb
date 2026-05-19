FactoryBot.define do
  factory :flash_campaign do
    association :tenant
    title { "Limited Edition Tee" }
    price { 990 }
    total_stock { 10 }
    remaining_stock { 10 }
    expired_at { 1.hour.from_now }

    # Trait for an expired campaign (used by fail-path specs).
    trait :expired do
      expired_at { 1.hour.ago }
    end

    # Trait for a campaign already drained (used by fail-path specs).
    trait :sold_out do
      total_stock { 5 }
      remaining_stock { 0 }
    end

    # Trait for a single-unit campaign (used by boundary specs).
    trait :last_unit do
      total_stock { 1 }
      remaining_stock { 1 }
    end
  end
end
