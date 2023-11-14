class Restaurant < ApplicationRecord
  validates :place_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :lat, presence: true
  validates :lng, presence: true
  has_many :photos, foreign_key: 'restaurant_id'
  has_many :favorites
  has_many :users, through: :favorites
end