require "rails_helper"

# FlashOrder is intentionally thin: a record of one fan's purchase against
# a campaign. The validations are the only behaviour worth exercising here.
RSpec.describe FlashOrder, type: :model do
  let(:campaign) { create(:flash_campaign) }

  # --- Happy path ---

  it "is valid with name + valid email + a campaign" do
    order = FlashOrder.new(flash_campaign: campaign, name: "A", email: "a@x.com")
    expect(order).to be_valid
  end

  # --- Fail path — validations ---

  it "is invalid without a name" do
    order = FlashOrder.new(flash_campaign: campaign, email: "a@x.com")
    expect(order).not_to be_valid
    expect(order.errors[:name]).to be_present
  end

  it "is invalid without an email" do
    order = FlashOrder.new(flash_campaign: campaign, name: "A")
    expect(order).not_to be_valid
    expect(order.errors[:email]).to be_present
  end

  it "is invalid when email format is malformed" do
    order = FlashOrder.new(flash_campaign: campaign, name: "A", email: "not-an-email")
    expect(order).not_to be_valid
    expect(order.errors[:email]).to be_present
  end

  it "is invalid without an associated flash_campaign" do
    order = FlashOrder.new(name: "A", email: "a@x.com")
    expect(order).not_to be_valid
  end
end
