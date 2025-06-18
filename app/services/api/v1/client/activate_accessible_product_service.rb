# frozen_string_literal: true

class Api::V1::Client::ActivateAccessibleProductService < Api::V1::BaseService
  def initialize(user:, product:, activation_code:, pin_code: nil)
    @user = user
    @product = product
    @activation_code = activation_code
    @pin_code = pin_code
  end

  def call
    card = find_card
    validate_card(card)
    accessible_product.active!
    accessible_product
  end

  private

  attr_reader :user, :product, :activation_code, :pin_code

  def find_card
    user.cards.find_by!(product_id: product.id)
  end

  def validate_card(card)
  end
end
