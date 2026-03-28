class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :orders
  has_many :flash_campaigns, dependent: :destroy

  # Automatically generate a unique token for new coaches
  before_create :generate_invitation_token

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true

  private

  def generate_invitation_token
    self.invitation_token = SecureRandom.hex(16)
  end
end