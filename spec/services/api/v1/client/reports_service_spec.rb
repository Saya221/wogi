# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Client::ReportsService, type: :service do
  describe "#call" do
    let(:client) { create(:client) }
    let!(:accessible_product1) { create(:accessible_product, user: client, product: create(:product, price: 100)) }
    let!(:accessible_product2) { create(:accessible_product, user: client, product: create(:product, price: 200)) }
    let!(:accessible_product3) { create(:accessible_product, user: client, product: create(:product, price: 300)) }
    let!(:card1) { create(:card, user: client, product: create(:product), state: :issued) }
    let!(:card2) { create(:card, user: client, product: create(:product), state: :approved) }
    let!(:card3) { create(:card, user: client, product: create(:product), state: :rejected) }

    subject(:service) { described_class.new(client: client) }

    it "returns the correct report data" do
      result = service.call

      expect(result[:total_products]).to eq(3)
      expect(result[:total_spends]).to eq(600)
      expect(result[:total_cards]).to eq(3)
      expect(result[:total_issued_cards]).to eq(1)
      expect(result[:total_approved_cards]).to eq(1)
      expect(result[:total_rejected_cards]).to eq(1)
    end
  end
end
