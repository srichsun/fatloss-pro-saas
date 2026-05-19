require 'rails_helper'

RSpec.describe FlashCampaign, type: :model do
  let(:tenant) { Tenant.create!(name: "Gym", subdomain: "gym") }

  def build_campaign(expired_at:)
    FlashCampaign.new(
      tenant: tenant,
      title: "Test",
      price: 100,
      total_stock: 10,
      remaining_stock: 10,
      expired_at: expired_at
    )
  end

  describe "#expired?" do
    it "is true when expired_at is in the past" do
      expect(build_campaign(expired_at: 1.minute.ago)).to be_expired
    end

    it "is false when expired_at is in the future" do
      expect(build_campaign(expired_at: 1.hour.from_now)).not_to be_expired
    end
  end
end
