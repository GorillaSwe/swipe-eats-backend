class Photo < ApplicationRecord
  belongs_to :restaurant
  validates :url, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
end
