# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Admin::CardsController, type: :controller do
  describe "GET #index" do
    let(:admin) { create(:admin) }
    let(:cards) { create_list(:card, 3) }

    describe "when admin is logged in" do
      context "when fetching all cards" do
        before do
          cards
          login(user: admin)
          get :index
        end

        it "returns a successful response" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:cards].size).to eq(3)
          expect(response_data[:meta]).to have_key(:pagy_info)
        end
      end

      context "when filter by user_id is applied" do
        let(:client) { create(:client) }
        let!(:filtered_card) { create(:card, user_id: client.id) }

        before do
          cards
          login(user: admin)
          get :index, params: { filter: { user_id: client.id } }
        end

        it "returns only the filtered cards" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:cards].size).to eq(1)
          expect(response_data[:data][:cards].first[:user][:id]).to eq(client.id)
        end
      end

      context "when sorting by state in descending order" do
        let!(:card_a) { create(:card, state: "approved") }
        let!(:card_b) { create(:card, state: "issued") }

        before do
          login(user: admin)
          get :index, params: { sort: { state: :desc } }
        end

        it "returns cards sorted by state in descending order" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:cards].map { |b| b[:state] }).to eq(["approved", "issued"])
        end
      end
    end

    describe "when user is not logged in" do
      it_behaves_like :unauthorized do
        before { get :index }
      end
    end

    describe "when client is logged in" do
      let(:client) { create(:client) }

      it_behaves_like :forbidden do
        before do
          login(user: client)
          get :index
        end
      end
    end
  end

  describe "PATCH #approved" do
    let(:admin) { create(:admin) }
    let(:card) { create(:card, state: "issued") }

    describe "when admin is logged in" do
      before do
        login(user: admin)
        patch :approved, params: { id: card.id }
      end

      context "when the card is successfully approved" do
        it "approves the card and creates an accessible product for the user" do
          expect(response).to have_http_status(:ok)
          expect(card.reload.state).to eq("approved")
          expect(card.user.accessible_products.exists?(product_id: card.product_id)).to be_truthy
        end
      end

      context "when the card is already approved" do
        let(:card) { create(:card, state: "approved") }

        it_behaves_like :invalid_card_state do
          before { patch :approved, params: { id: card.id } }
        end
      end

      context "when the card is rejected" do
        let(:card) { create(:card, state: "rejected") }

        it_behaves_like :invalid_card_state do
          before { patch :approved, params: { id: card.id } }
        end
      end

      context "when the card is not found" do
        it_behaves_like :not_found, "card" do
          before { patch :approved, params: { id: -1 } }
        end
      end
    end

    context "when the user already has the product" do
      let(:admin) { create(:admin) }
      let(:existing_product) { create(:product) }
      let(:client) { create(:client) }
      let(:card) { create(:card, state: "issued", product: existing_product, user: client) }
      let!(:accessible_product) { create(:accessible_product, user: client, product: existing_product) }

      before do
        login(user: admin)
        patch :approved, params: { id: card.id }
      end

      it_behaves_like :taken, "accessible_product", "product_id"
    end

    describe "when user is not logged in" do
      it_behaves_like :unauthorized do
        before { patch :approved, params: { id: card.id } }
      end
    end

    describe "when client is logged in" do
      let(:client) { create(:client) }

      it_behaves_like :forbidden do
        before do
          login(user: client)
          patch :approved, params: { id: card.id }
        end
      end
    end

    describe "when card state is not issued" do
      let(:card) { create(:card, state: "rejected") }

      it_behaves_like :invalid_card_state do
        before do
          login(user: admin)
          patch :approved, params: { id: card.id }
        end
      end
    end
  end

  describe "PATCH #rejected" do
    let(:admin) { create(:admin) }
    let(:card) { create(:card, state: "issued") }

    describe "when admin is logged in" do
      before do
        login(user: admin)
        patch :rejected, params: { id: card.id }
      end

      context "when the card is successfully rejected" do
        it "rejects the card" do
          expect(response).to have_http_status(:ok)
          expect(card.reload.state).to eq("rejected")
        end
      end

      context "when the card is already rejected" do
        let(:card) { create(:card, state: "rejected") }

        it_behaves_like :invalid_card_state do
          before { patch :rejected, params: { id: card.id } }
        end
      end

      context "when the card is already approved" do
        let(:card) { create(:card, state: "approved") }

        it_behaves_like :invalid_card_state do
          before { patch :rejected, params: { id: card.id } }
        end
      end

      context "when the card is not found" do
        it_behaves_like :not_found, "card" do
          before { patch :rejected, params: { id: -1 } }
        end
      end
    end

    describe "when user is not logged in" do
      it_behaves_like :unauthorized do
        before { patch :rejected, params: { id: card.id } }
      end
    end

    describe "when client is logged in" do
      let(:client) { create(:client) }

      it_behaves_like :forbidden do
        before do
          login(user: client)
          patch :rejected, params: { id: card.id }
        end
      end
    end

    describe "when card state is not issued" do
      let(:card) { create(:card, state: "approved") }

      it_behaves_like :invalid_card_state do
        before do
          login(user: admin)
          patch :rejected, params: { id: card.id }
        end
      end
    end
  end
end
