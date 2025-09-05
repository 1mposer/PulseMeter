class Item < ApplicationRecord
  has_many :drink_purchases, dependent: :nullify
  has_many :food_purchases, dependent: :nullify
  
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :category, presence: true, inclusion: { in: %w[drink food] }

  scope :drinks, -> { where(category: "drink") }
  scope :food, -> { where(category: "food") }
  scope :in_stock, -> { where("stock_quantity > 0") }

  def drink?
    category == "drink"
  end

  def food?
    category == "food"
  end

  def in_stock?
    stock_quantity > 0
  end

  def current_price
    price
  end
end
