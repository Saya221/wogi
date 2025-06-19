# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CardSerializer do
  let(:current_time) { Time.zone.parse("2024-01-01 12:00:00").to_i }
  let(:user) do
    create :user,
           id: "b1e1e1e1-e1e1-4e1e-b1e1-e1e1e1e1e1e1",
           name: "Card User",
           email: "user@example.com",
           state: "active",
           created_at: Time.zone.parse("2024-01-01 12:00:00"),
           updated_at: Time.zone.parse("2024-01-01 12:00:00")
  end
  let(:product) do
    create :product,
           id: "c2f2f2f2-f2f2-4f2f-c2f2-f2f2f2f2f2f2",
           name: "Card Product",
           brand: create(:brand, id: "d3a3a3a3-a3a3-4a3a-d3a3-a3a3a3a3a3a3"),
           description: "Product desc",
           price: 99.99,
           state: "active",
           created_at: Time.zone.parse("2024-01-01 12:00:00"),
           updated_at: Time.zone.parse("2024-01-01 12:00:00")
  end

  describe "serialize card (ROOT fields)" do
    let(:card) do
      create :card,
             id: "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
             user:,
             product:,
             state: "issued",
             activation_code: nil,
             created_at: Time.zone.parse("2024-01-01 12:00:00"),
             updated_at: Time.zone.parse("2024-01-01 12:00:00")
    end
    let(:response_data) { described_class.new(card).to_hash }
    let(:expected_data) do
      {
        id: "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
        user: Api::V1::UserSerializer.new(user).to_hash,
        product: Api::V1::ProductSerializer.new(product).to_hash,
        state: "issued",
        created_at: current_time,
        updated_at: current_time
      }
    end

    it { expect(response_data).to eq expected_data }
  end

  describe "serialize approved card (APPROVED_CARD fields)" do
    let(:approved_card) do
      create :card,
             id: "b2c3d4e5-f6a7-8901-bcde-fa2345678901",
             user:,
             product:,
             state: "approved",
             activation_code: "ABC123",
             pin_code: "1234",
             created_at: Time.zone.parse("2024-01-01 12:00:00"),
             updated_at: Time.zone.parse("2024-01-01 12:00:00")
    end
    let(:response_data) { described_class.new(approved_card, type: :approved_card).to_hash }
    let(:expected_data) do
      {
        id: "b2c3d4e5-f6a7-8901-bcde-fa2345678901",
        user: Api::V1::UserSerializer.new(user).to_hash,
        product: Api::V1::ProductSerializer.new(product).to_hash,
        state: "approved",
        activation_code: "ABC123",
        pin_code: "1234",
        created_at: current_time,
        updated_at: current_time
      }
    end

    it { expect(response_data).to eq expected_data }
  end
end
