# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AdminSerializer do
  let(:current_time) { Time.zone.parse("2024-01-01 12:00:00").to_i }
  let(:admin) do
    create :admin,
      id: "abc12345-6789-0abc-def1-234567890abc",
      name: "Admin User",
      email: "admin@example.com",
      state: "active",
      created_at: Time.zone.parse("2024-01-01 12:00:00"),
      updated_at: Time.zone.parse("2024-01-01 12:00:00")
  end

  describe "serialize type is root" do
    let(:response_data) { described_class.new(admin).to_hash }
    let(:expected_data) do
      {
        id: "abc12345-6789-0abc-def1-234567890abc",
        name: "Admin User",
        email: "admin@example.com",
        type: "Admin",
        state: "active",
        created_at: current_time,
        updated_at: current_time
      }
    end

    it { expect(response_data).to eq expected_data }
  end
end
