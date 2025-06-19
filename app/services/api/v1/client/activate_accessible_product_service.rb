# frozen_string_literal: true

class Api::V1::Client::ActivateAccessibleProductService < Api::V1::BaseService
  def initialize(user:, product:, card:, activation_code:, pin_code: nil)
    @user = user
    @product = product
    @card = card
    @activation_code = activation_code
    @pin_code = pin_code
  end

  def call
    validate_card
    accessible_product.active!
    accessible_product
  end

  private

  attr_reader :user, :product, :card, :activation_code, :pin_code

  def accessible_product
    @accessible_product ||= AccessibleProduct.find_by!(
      user:,
      product:,
      state: :inactive
    )
  end

  def validate_card
    raise Api::Error::ServiceExecuteFailed, :invalid_card_state unless card.approved?
    raise Api::Error::ServiceExecuteFailed, :invalid_activation_code unless card.activation_code == activation_code
    raise Api::Error::ServiceExecuteFailed, :invalid_pin_code if card.pin_code.present? && card.pin_code != pin_code
  end
end
