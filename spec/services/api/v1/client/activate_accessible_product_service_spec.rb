# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Client::ActivateAccessibleProductService, type: :service do
  describe "#call" do
    let(:user) { create(:user) }
    let(:product) { create(:product) }
    let(:card) { create(:card, user: user, product: product) }
    let(:activation_code) { "123456" }
    let(:pin_code) { "1234" }
    let!(:accessible_product) { create(:accessible_product, user: user, product: product, state: :inactive) }

    subject(:service) do
      described_class.new(
        user: user,
        product: product,
        card: card,
        activation_code: activation_code,
        pin_code: pin_code
      )
    end

    context "when the card is valid" do
      before do
        allow(card).to receive(:approved?).and_return(true)
        allow(card).to receive(:activation_code).and_return(activation_code)
        allow(card).to receive(:pin_code).and_return(pin_code)
      end

      it "activates the accessible product" do
        expect { service.call }.to change { user.accessible_products.active.count }.by(1)
      end
    end

    context "when the card is not approved" do
      before do
        allow(card).to receive(:approved?).and_return(false)
      end

      it "raises an error" do
        expect { service.call }.to raise_error(Api::Error::ServiceExecuteFailed)
      end
    end

    context "when the activation code is invalid" do
      before do
        allow(card).to receive(:approved?).and_return(true)
        allow(card).to receive(:activation_code).and_return("wrong_code")
      end

      it "raises an error" do
        expect { service.call }.to raise_error(Api::Error::ServiceExecuteFailed)
      end
    end

    context "when the pin code is invalid" do
      before do
        allow(card).to receive(:approved?).and_return(true)
        allow(card).to receive(:activation_code).and_return(activation_code)
        allow(card).to receive(:pin_code).and_return("wrong_pin")
      end

      it "raises an error" do
        expect { service.call }.to raise_error(Api::Error::ServiceExecuteFailed)
      end
    end
  end
end
