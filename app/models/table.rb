class Table < ApplicationRecord
  has_many :tags, dependent: :destroy
  has_many :sessions, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :default_price_per_minute, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }

  def current_session
    sessions.open_only.first
  end

  def available?
    current_session.nil?
  end
end

