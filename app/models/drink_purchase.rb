class DrinkPurchase < ApplicationRecord
  belongs_to :session
  belongs_to :item
  belongs_to :member, optional: true

  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :unit_price_at_sale, presence: true, numericality: { greater_than: 0 }
  validates :total_price, presence: true, numericality: { greater_than: 0 }
  
  validate :item_must_be_drink_category
  validate :session_must_be_open
  validate :sufficient_stock_available

  before_validation :calculate_total_price
  after_create :update_stock_and_member_totals

  private

  def calculate_total_price
    self.total_price = quantity * unit_price_at_sale if quantity && unit_price_at_sale
  end

  def item_must_be_drink_category
    return unless item
    
    errors.add(:item, "must be a drink") unless item.category == "drink"
  end

  def session_must_be_open
    return unless session
    
    errors.add(:session, "must be open") unless session.status == "open"
  end

  def sufficient_stock_available
    return unless item && quantity

    if item.stock_quantity < quantity
      errors.add(:quantity, "exceeds available stock (#{item.stock_quantity} available)")
    end
  end

  def update_stock_and_member_totals
    # Subtract from the item's stock (validation ensures sufficient stock)
    item.decrement!(:stock_quantity, quantity)

    # Update member total spent on drinks (if member exists)
    member&.increment!(:total_spent_drinks, total_price)
  end
end
