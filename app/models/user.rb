class User < ApplicationRecord
  has_secure_password
  belongs_to :tenant

  validates :name, presence: true

  enum :role, { coach: 0, client: 1 }
end
