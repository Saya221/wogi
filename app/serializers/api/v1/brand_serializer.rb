# frozen_string_literal: true

class Api::V1::BrandSerializer < Api::V1::BaseSerializer
  attributes %i[id name state description country created_at updated_at]

  def attributes(*attrs)
    super.slice(*fields_custom[:brands])
  end

  def created_at
    object.created_at.to_i
  end

  def updated_at
    object.updated_at.to_i
  end

  ROOT = {
    brands: %i[id name state description country created_at updated_at]
  }.freeze

  BRAND_INDEX_INFO = {
    brands: %i[id name]
  }.freeze
end
