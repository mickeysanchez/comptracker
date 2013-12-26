class Comp < ActiveRecord::Base
  belongs_to :account
  
  validates :expiration, presence: true
end
