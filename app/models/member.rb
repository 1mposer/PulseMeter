class Member < ApplicationRecord
  has_many :sessions, foreign_key: :membership_id, dependent: :nullify
  has_many :drink_purchases, dependent: :nullify
  has_many :food_purchases, dependent: :nullify
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :total_spent_sessions, numericality: { greater_than_or_equal_to: 0 }
  validates :total_spent_drinks, numericality: { greater_than_or_equal_to: 0 }

  def total_purchases
    total_spent_sessions + total_spent_drinks
  end

  def lifetime_value
    total_purchases
  end
end
