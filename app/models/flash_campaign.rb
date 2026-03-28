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
end