# frozen_string_literal: true

class Card < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :user
  belongs_to :product

  validates :activation_code, uniqueness: true, allow_blank: true
  validates :user_id, uniqueness: { scope: :product_id }

  enum :state, %i[issued approved rejected]

  before_save :generate_activation_code, if: :should_generate_activation_code?

  private

  def should_generate_activation_code?
    approved? && activation_code.blank? && (new_record? || state_changed_to_approved?)
  end

  def state_changed_to_approved?
    state_changed? && state_was != self.class.states[:approved]
  end

  def generate_activation_code
    self.activation_code = loop do
      code = SecureRandom.hex(Settings.activation_code_length).upcase
      break code unless activation_code_exists?(code)
    end
  end

  def activation_code_exists?(code)
    self.class.unscoped.exists?(activation_code: code)
  end
end
