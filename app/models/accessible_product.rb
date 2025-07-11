# frozen_string_literal: true

class AccessibleProduct < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :product
  belongs_to :user

  enum :state, %i[inactive active]

  validates :product_id, uniqueness: { scope: :user_id }
end
