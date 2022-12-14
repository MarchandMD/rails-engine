class Item < ApplicationRecord
  belongs_to :merchant

  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true

  def self.search(input)
    where("name ILIKE ?", "%#{input}%")
  end

  # :nocov:
  def self.check_params(params)
    params
  end
  # :nocov:
end
