# frozen_string_literal: true

class Api::V1::ProductSerializer < Api::V1::BaseSerializer
  attributes %i[id name brand description price state created_at updated_at]

  def attributes(*attrs)
    super.slice(*fields_custom[:products])
  end

  def brand
    Api::V1::BrandSerializer.new(object.brand, type: :brand_index_info).to_hash
  end

  def created_at
    object.created_at.to_i
  end

  def updated_at
    object.updated_at.to_i
  end

  ROOT = {
    products: %i[id name brand description price state created_at updated_at]
  }.freeze
end
