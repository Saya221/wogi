# frozen_string_literal: true

class Api::V1::CardSerializer < Api::V1::BaseSerializer
  attributes %i[id user product state activation_code pin_code created_at updated_at]

  def attributes(*attrs)
    super.slice(*fields_custom[:cards])
  end

  def user
    "Api::V1::#{object.user.class}Serializer".constantize.new(object.user).to_hash
  end

  def activation_code
    return unless fields_custom[:cards].include?(:activation_code)

    object.activation_code
  end

  def pin_code
    return unless fields_custom[:cards].include?(:pin_code)

    object.pin_code
  end

  def product
    Api::V1::ProductSerializer.new(object.product).to_hash
  end

  def created_at
    object.created_at.to_i
  end

  def updated_at
    object.updated_at.to_i
  end

  ROOT = {
    cards: %i[id user product state created_at updated_at]
  }.freeze

  APPROVED_CARD = {
    cards: %i[id user product state activation_code pin_code created_at updated_at]
  }.freeze
end
