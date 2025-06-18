# frozen_string_literal: true

require "rails_helper"

RSpec.describe Client, type: :model do
  # Inherits from User (STI)
  describe "associations" do
    it { is_expected.to have_many(:cards).with_foreign_key(:user_id).dependent(:destroy) }
  end

  describe "validations" do
    context "payout_rate" do
      let(:min) { Settings.payout_rate.min }
      let(:max) { Settings.payout_rate.max }

      [
        { payout_rate: ->(min, _) { min - 0.01 }, valid: false, desc: "below minimum" },
        { payout_rate: ->(_, max) { max + 0.01 }, valid: false, desc: "above maximum" },
        { payout_rate: ->(min, max) { (min + max) / 2.0 }, valid: true, desc: "within range" },
        { payout_rate: ->(_, _) { "abc" }, valid: false, desc: "non-numeric" },
        { payout_rate: ->(_, _) { nil }, valid: false, desc: "nil" }
      ].each do |test_case|
        it "is #{test_case[:valid] ? 'valid' : 'not valid'} with a payout_rate #{test_case[:desc]}" do
          value = test_case[:payout_rate].call(min, max)
          client = build(:client, payout_rate: value)
          if test_case[:valid]
            expect(client).to be_valid
          else
            expect(client).not_to be_valid
          end
        end
      end
    end
  end

  describe "instance methods" do
    it_behaves_like :filter_and_sort
  end
end
