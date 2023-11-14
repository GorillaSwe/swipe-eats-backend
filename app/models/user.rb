class User < ApplicationRecord
  has_many :favorites
  has_many :restaurants, through: :favorites
  
  def self.from_token_payload(payload)
    find_by(uid: payload['sub'])
  end
end
