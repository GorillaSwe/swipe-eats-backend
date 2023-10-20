class Photo < ApplicationRecord
  belongs_to :restaurant, foreign_key: 'restaurant_id'
  validates :url, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
end
