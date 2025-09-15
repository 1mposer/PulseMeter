class CompletedSession < ApplicationRecord
  belongs_to :session, optional: true
  belongs_to :member,  optional: true
  belongs_to :table,   optional: true
  
  validates :session_id, presence: true
  validates :duration_mins, presence: true, numericality: { greater_than: 0 }
  validates :total_cost, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :receipt, presence: true
  validates :completed_at, presence: true
  validates :price_per_min, presence: true, numericality: { greater_than: 0 }
end
