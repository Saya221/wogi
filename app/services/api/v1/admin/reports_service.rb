# frozen_string_literal: true

class Api::V1::Admin::ReportsService < Api::V1::BaseService
  def initialize(client:, brand:)
    @client = client
    @brand = brand
  end

  def call
    {
      client: {
        total_products: client.products.count,
        total_brands: client.brands.count,
        total_spends: client_products.sum(:price),
      },
      brand: {
        total_products: brand_products.count,
        total_spends: brand_products.sum(:price)
      }
    }
  end

  private

  attr_reader :client, :brand

  def client_products
    @client_products ||= client.products
  end

  def brand_products
    @brand_products ||= brand.products
  end
end
