class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true
end