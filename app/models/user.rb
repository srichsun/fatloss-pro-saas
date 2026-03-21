class User < ApplicationRecord
  has_secure_password 
  belongs_to :tenant
  
  enum :role, { coach: 0, student: 1 } 
end