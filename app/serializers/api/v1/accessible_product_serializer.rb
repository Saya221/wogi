# frozen_string_literal: true

class Api::V1::AccessibleProductSerializer < Api::V1::BaseSerializer
  attributes %i[id user product state created_at updated_at]

  def user
    "Api::V1::#{object.user.class}Serializer".constantize.new(object.user).to_hash
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
    accessible_product: %i[id user product state created_at updated_at]
  }.freeze
end
