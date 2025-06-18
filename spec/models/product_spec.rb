# frozen_string_literal: true

require "rails_helper"

RSpec.describe Product, type: :model do
  it_behaves_like :concerns

  describe "relationships" do
    it { is_expected.to belong_to(:brand) }
    it { is_expected.to have_many(:accessible_products).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:accessible_products) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:state).with_values(inactive: 0, active: 1) }
  end

  describe "validations" do
    context "name" do
      let(:product) { build(:product, name: nil) }

      it "is not valid without a name" do
        expect(product).not_to be_valid
      end
    end

    context "price" do
      [
        { price: -1, valid: false, desc: "negative price" },
        { price: 0.05, valid: false, desc: "price below minimum" },
        { price: 0.1, valid: false, desc: "price equal to minimum" },
        { price: 1.0, valid: true, desc: "price above minimum" },
        { price: nil, valid: false, desc: "nil price" },
        { price: "abc", valid: false, desc: "non-numeric price" }
      ].each do |test_case|
        it "is #{test_case[:valid] ? 'valid' : 'not valid'} with a #{test_case[:desc]}" do
          product = build(:product, price: test_case[:price])
          if test_case[:valid]
            expect(product).to be_valid
          else
            expect(product).not_to be_valid
          end
        end
      end
    end
  end

  describe "instance methods" do
    it_behaves_like :filter_and_sort
  end
end
