# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin, type: :model do
  # Inherits from User (STI)

  describe "instance methods" do
    describe "#payout_rate" do
      let(:admin) { build(:admin) }

      it "raises NoMethodError for payout_rate getter" do
        expect { admin.payout_rate }.to raise_error(NoMethodError, /payout_rate is not implemented for Admin/)
      end

      it "raises NoMethodError for payout_rate setter" do
        expect do
          admin.payout_rate = 1.0
        end.to raise_error(NoMethodError, /payout_rate= is not implemented for Admin/)
      end
    end
  end
end
