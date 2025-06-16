# frozen_string_literal: true

class Client < User
  validates :payout_rate, numericality: { greater_than: Settings.payout_rate.min, less_than: Settings.payout_rate.max }

  has_many :cards, dependent: :destroy
end
