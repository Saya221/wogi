# frozen_string_literal: true

class Product < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :brand

  has_many :accessible_products, dependent: :destroy
  has_many :users, through: :accessible_products

  enum :state, %i[inactive active]

  validates :name, presence: true
  validates :price, numericality: { greater_than: Settings.product.price.min }
end
