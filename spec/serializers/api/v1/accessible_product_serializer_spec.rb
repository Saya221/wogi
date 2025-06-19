# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AccessibleProductSerializer do
  let(:accessible_product) { create(:accessible_product) }
  let(:serializer) { described_class.new(accessible_product) }

  describe "#to_hash" do
    it "returns the serialized hash" do
      expected_hash = {
        id: accessible_product.id,
        user: "Api::V1::#{accessible_product.user.class}Serializer".constantize.new(accessible_product.user).to_hash,
        product: Api::V1::ProductSerializer.new(accessible_product.product).to_hash,
        state: accessible_product.state,
        created_at: accessible_product.created_at.to_i,
        updated_at: accessible_product.updated_at.to_i
      }

      expect(serializer.to_hash).to eq(expected_hash)
    end
  end

  describe "ROOT constant" do
    it "defines the correct attributes" do
      expect(described_class::ROOT[:accessible_product]).to eq(
        %i[id user product state created_at updated_at]
      )
    end
  end
end
