class User < ApplicationRecord
  has_secure_password
  belongs_to :tenant

  validates :name, presence: true
end
