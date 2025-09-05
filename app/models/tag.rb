class Tag < ApplicationRecord
  belongs_to :table
  has_many :sessions, dependent: :nullify

  validates :token, presence: true, uniqueness: true
  validates :table_id, presence: true

  scope :active, -> { where(active: true) }

  def self.find_by_token!(token)
    active.find_by!(token: token)
  end
end