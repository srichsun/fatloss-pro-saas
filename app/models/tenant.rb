class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :flash_campaigns, dependent: :destroy

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true
end
