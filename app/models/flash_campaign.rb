class FlashCampaign < ApplicationRecord
  # Each campaign belongs to a specific coach/tenant
  belongs_to :tenant
  
  # A campaign can have many orders
  has_many :flash_orders, dependent: :destroy

  # Set up image attachment via Active Storage
  has_one_attached :product_image

  # Basic validations to ensure data integrity
  validates :title, :price, :total_stock, :expired_at, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  # Get remaining stock from Redis cache for high-speed reading
  def cached_remaining_stock
    Rails.cache.fetch("campaign_#{id}_stock", expires_in: 1.minute) do
      puts "-----> MISS: FETCHING FROM DATABASE <-----"
      remaining_stock
    end
  end

  # Update cache whenever stock changes in DB
  after_save :update_stock_cache

  private

  def update_stock_cache
    Rails.cache.write("campaign_#{id}_stock", remaining_stock)
  end
end