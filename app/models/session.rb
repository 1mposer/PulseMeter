
class Session < ApplicationRecord
  belongs_to :table, optional: true
  belongs_to :tag, optional: true
  belongs_to :member, optional: true, foreign_key: :membership_id
  
  has_many :drink_purchases, dependent: :destroy
  has_many :food_purchases, dependent: :destroy

  validates :price_per_minute, presence: true, numericality: { greater_than: 0 }
  validates :time_in, presence: true
  validate :time_out_must_be_after_time_in, if: -> { time_out.present? && time_in.present? }
  validate :only_one_open_session_per_table, on: :create

  scope :open_only, -> { where(time_out: nil, voided_at: nil) }
  scope :closed_only, -> { where.not(time_out: nil).where(voided_at: nil) }
  scope :voided_only, -> { where.not(voided_at: nil) }

  def duration_minutes
    return 0 unless time_in
    return ((Time.current - time_in) / 60).ceil if time_out.nil? # Estimated for open sessions
    return ((time_out - time_in) / 60).ceil
  end

  def table_total
    return 0 unless duration_minutes && price_per_minute
    duration_minutes * price_per_minute
  end

  def drinks_total
    drink_purchases.sum(:total_price)
  end

  def food_total
    food_purchases.sum(:total_price)
  end

  def subtotal
    table_total + drinks_total + food_total
  end

  def grand_total
    return 0 if voided?
    subtotal
  end

  def status
    return "voided" if voided_at.present?
    return "closed" if time_out.present?
    "open"
  end

  def open?
    status == "open"
  end

  def closed?
    status == "closed"
  end

  def voided?
    status == "voided"
  end

  def close!(close_time = Time.current)
    return false unless open?
    
    update!(time_out: close_time)
    # Archive to CompletedSession will be implemented later
  end

  def void!(reason)
    return false if closed?
    
    update!(
      voided_at: Time.current,
      void_reason: reason
    )
  end

  private

  def time_out_must_be_after_time_in
    return unless time_out && time_in
    
    errors.add(:time_out, "must be after time_in") if time_out <= time_in
  end

  def only_one_open_session_per_table
    return unless table_id && open?
    
    existing_open = Session.joins(:table)
                          .where(table_id: table_id, time_out: nil, voided_at: nil)
                          .where.not(id: id)
                          .exists?
    
    errors.add(:table, "already has an open session") if existing_open
  end
end