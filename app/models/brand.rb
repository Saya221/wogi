# frozen_string_literal: true

class Brand < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  has_many :products, dependent: :destroy

  enum :state, %i[inactive active]

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
