class FoodPurchase < ApplicationRecord
  belongs_to :session
  belongs_to :item
  belongs_to :member, optional: true

  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :unit_price_at_sale, presence: true, numericality: { greater_than: 0 }
  validates :total_price, presence: true, numericality: { greater_than: 0 }
  
  validate :item_must_be_food_category
  validate :session_must_be_open

  before_validation :calculate_total_price
  after_create :update_stock_and_member_totals

  private

  def calculate_total_price
    self.total_price = quantity * unit_price_at_sale if quantity && unit_price_at_sale
  end

  def item_must_be_food_category
    return unless item
    
    errors.add(:item, "must be a food item") unless item.category == "food"
  end

  def session_must_be_open
    return unless session
    
    errors.add(:session, "must be open") unless session.status == "open"
  end

  def update_stock_and_member_totals
    # Subtract from the item's stock
    item.decrement!(:stock_quantity, quantity) if item.stock_quantity >= quantity

    # Update member total spent on food (we'll add this field later if needed)
    # For now, we could track total purchases or add a total_spent_food field to members
  end
end