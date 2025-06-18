# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProductSerializer do
  let(:current_time) { Time.zone.parse("2024-01-01 12:00:00").to_i }
  let(:brand) { create(:brand, id: "7926197c-7133-461c-aeab-d18ba6c6044e", name: "BrandName") }
  let(:product) do
    create :product,
      id: "7926197c-7133-461c-aeab-d18ba6c6044d",
      name: "Product Name",
      brand: brand,
      description: "A product description",
      price: 123.45,
      state: "active",
      created_at: Time.zone.parse("2024-01-01 12:00:00"),
      updated_at: Time.zone.parse("2024-01-01 12:00:00")
  end

  describe "serialize type is root" do
    let(:response_data) { described_class.new(product).to_hash }
    let(:expected_data) do
      {
        id: "7926197c-7133-461c-aeab-d18ba6c6044d",
        name: "Product Name",
        brand: Api::V1::BrandSerializer.new(brand, type: :brand_index_info).to_hash,
        description: "A product description",
        price: 123.45,
        state: "active",
        created_at: current_time,
        updated_at: current_time
      }
    end

    it { expect(response_data).to eq expected_data }
  end
end
