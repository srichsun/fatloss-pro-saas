class FlashOrder < ApplicationRecord
  # Link the order back to the campaign
  belongs_to :flash_campaign

  # Ensure essential fan info is present
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
end