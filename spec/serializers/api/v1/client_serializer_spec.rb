# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ClientSerializer do
  let(:current_time) { Time.zone.parse("2024-01-01 12:00:00").to_i }
  let(:user) do
    create :client,
           id: "123e4567-e89b-12d3-a456-426614174000",
           name: "Test User",
           email: "test@example.com",
           state: "active",
           payout_rate: 10.5,
           created_at: Time.zone.parse("2024-01-01 12:00:00"),
           updated_at: Time.zone.parse("2024-01-01 12:00:00")
  end

  describe "serialize type is root" do
    let(:response_data) { described_class.new(user).to_hash }
    let(:expected_data) do
      {
        id: "123e4567-e89b-12d3-a456-426614174000",
        name: "Test User",
        email: "test@example.com",
        state: "active",
        payout_rate: 10.5,
        created_at: current_time,
        updated_at: current_time
      }
    end

    it { expect(response_data).to eq expected_data }
  end
end
