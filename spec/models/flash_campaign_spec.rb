require "rails_helper"

RSpec.describe FlashCampaign, type: :model do
  let(:tenant) { create(:tenant) }

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

  # --- Happy path ---

  describe "#expired?" do
    it "is false when expired_at is in the future" do
      expect(build_campaign(expired_at: 1.hour.from_now)).not_to be_expired
    end
  end

  # --- Boundary ---

  describe "#expired? boundary" do
    it "is true when expired_at is in the past" do
      expect(build_campaign(expired_at: 1.minute.ago)).to be_expired
    end
  end

  # --- Caching behaviour ---
  #
  # remaining_stock is hot data: read by both the public landing page and
  # the buy endpoint. The model wraps it in Rails.cache so the public page
  # avoids a DB roundtrip per fan; the after_save callback keeps the cache
  # consistent with DB writes.
  describe "stock caching" do
    # Test env defaults to :null_store, so swap in a real memory store for
    # the spec block and put it back afterwards.
    around do |example|
      original = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      example.run
    ensure
      Rails.cache = original
    end

    let(:campaign) { create(:flash_campaign, total_stock: 50, remaining_stock: 50) }
    let(:cache_key) { "campaign_#{campaign.id}_stock" }

    before { Rails.cache.clear }

    # --- Happy path ---

    it "writes remaining_stock into Rails.cache after save" do
      expect(Rails.cache.read(cache_key)).to eq(campaign.remaining_stock)
    end

    it "updates the cache when remaining_stock changes" do
      campaign.update!(remaining_stock: 42)
      expect(Rails.cache.read(cache_key)).to eq(42)
    end

    # --- Happy path — read path ---

    it "returns the cached value via #cached_remaining_stock" do
      expect(campaign.cached_remaining_stock).to eq(50)
    end

    # --- Edge — cache miss falls back to DB ---

    it "falls back to the DB value when the cache entry is missing" do
      Rails.cache.delete(cache_key)
      expect(campaign.cached_remaining_stock).to eq(campaign.remaining_stock)
    end
  end
end
