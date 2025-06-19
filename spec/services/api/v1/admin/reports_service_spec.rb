# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Admin::ReportsService, type: :service do
  describe "#call" do
    let(:client) { create(:client) }
    let(:brand) { create(:brand) }
    let!(:accessible_product1) { create(:accessible_product, user: client, product: product1) }
    let!(:accessible_product2) { create(:accessible_product, user: client, product: product2) }
    let!(:accessible_product3) { create(:accessible_product, user: client, product: product3) }
    let(:product1) { create(:product, brand: brand, price: 100) }
    let(:product2) { create(:product, brand: brand, price: 200) }
    let(:product3) { create(:product, brand: create(:brand), price: 300) }

    subject(:service) { described_class.new(client: client, brand: brand) }

    it "returns the correct report data" do
      result = service.call

      expect(result[:client][:total_products]).to eq(3)
      expect(result[:client][:total_brands]).to eq(3)
      expect(result[:client][:total_spends]).to eq(600)

      expect(result[:brand][:total_products]).to eq(2)
      expect(result[:brand][:total_spends]).to eq(300)
    end
  end
end
