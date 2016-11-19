class Record < ApplicationRecord
  validates :name, :email, :city, :country, :comments, presence: true
  validates :state, length: { maximum: 2 }
end
