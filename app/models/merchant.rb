class Merchant < ApplicationRecord
  has_many :items, dependent: :destroy

  validates :name, presence: true

  def self.find_items_merchant(item_id)
    find(Item.find(item_id).merchant_id)
  end
end