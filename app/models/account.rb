class Account < ActiveRecord::Base
  belongs_to :user
  has_many :comps, dependent: :destroy
  
  validates :username, presence: true
  validates :user_id, presence: true
  validates :password_digest, presence: true
  
  # has_secure_password
end
