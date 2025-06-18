# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Client::CardsController, type: :controller do
  describe "GET #index" do
    let(:client) { create(:client) }
    let(:cards) { create_list(:card, 3, user: client) }

    describe "when client is logged in" do
      context "when fetching all cards" do
        before do
          cards
          login(user: client)
          get :index
        end

        it "returns a successful response" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:cards].size).to eq(3)
          expect(response_data[:meta]).to have_key(:pagy_info)
        end
      end

      context "when filter by state is applied" do
        let(:client) { create(:client) }
        let!(:filtered_card) { create(:card, user_id: client.id, state: :approved) }

        before do
          cards
          login(user: client)
          get :index, params: { filter: { state: :approved } }
        end

        it "returns only the filtered cards" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:cards].size).to eq(1)
          expect(response_data[:data][:cards].first[:state]).to eq "approved"
        end
      end

      context "when sorting by state in descending order" do
        let!(:card_a) { create(:card, state: "approved", user: client) }
        let!(:card_b) { create(:card, state: "issued", user: client) }

        before do
          login(user: client)
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

    describe "when admin is logged in" do
      let(:admin) { create(:admin) }

      it_behaves_like :forbidden do
        before do
          login(user: admin)
          get :index
        end
      end
    end
  end

  describe "GET #show" do
    let(:client) { create(:client) }

    describe "when client is logged in" do
      before do
        login(user: client)
        get :show, params: { id: card_id }
      end

      context "when card exists" do
        let(:card_id) { card.id }

        context "when card is issued or rejected" do
          let(:card) { create(:card, user: client, state: "issued") }

          it "returns the card details" do
            expect(response).to have_http_status(:ok)
            expect(response_data[:data][:card][:id]).to eq(card.id)
            expect(response_data[:data][:card]).not_to have_key(:pin_code)
            expect(response_data[:data][:card]).not_to have_key(:activation_code)
          end
        end

        context "when card is approved" do
          let(:card) { create(:card, user: client, state: "approved") }

          it "returns the card details with pin_code and activation_code" do
            expect(response).to have_http_status(:ok)
            expect(response_data[:data][:card][:id]).to eq(card.id)
            expect(response_data[:data][:card]).to have_key(:pin_code)
            expect(response_data[:data][:card]).to have_key(:activation_code)
          end
        end
      end

      context "when card does not exist" do
        let(:card_id) { -1 }

        it_behaves_like :not_found, "card"
      end
    end

    describe "when user is not logged in" do
      let(:client) { create(:client) }
      let(:card) { create(:card, user: client) }

      it_behaves_like :unauthorized do
        before { get :show, params: { id: card.id } }
      end
    end

    describe "when admin is logged in" do
      let(:admin) { create(:admin) }
      let(:client) { create(:client) }
      let(:card) { create(:card, user: client) }

      it_behaves_like :forbidden do
        before do
          login(user: admin)
          get :show, params: { id: card.id }
        end
      end
    end
  end

  describe "POST #create" do
    describe "when client is logged in" do
      let(:client) { create(:client) }

      before { login(user: client) }

      context "with valid parameters" do
        before { post :create, params: { card: { product_id: product.id } } }

        let(:product) { create(:product) }

        it "creates a new card" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:card][:product][:id]).to eq(product.id)
          expect(response_data[:data][:card][:user][:id]).to eq(client.id)
        end
      end

      context "with invalid parameters" do
        before { post :create, params: { card: { product_id: nil } } }

        it_behaves_like :blank, "card", "product"
      end
    end

    describe "when user is not logged in" do
      it_behaves_like :unauthorized do
        before { post :create }
      end
    end

    describe "when admin is logged in" do
      let(:admin) { create(:admin) }

      it_behaves_like :forbidden do
        before do
          login(user: admin)
          post :create, params: { card: { product_id: 1 } }
        end
      end
    end
  end

  describe "PUT #update" do
    let(:client) { create(:client) }
    let(:card) { create(:card, user: client) }
    let(:product) { create(:product) }

    describe "when client is logged in" do
      before { login(user: client) }

      context "with valid parameters" do
        before { put :update, params: { id: card.id, card: { product_id: product.id } } }

        it "updates the card" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:card][:product][:id]).to eq(product.id)
          expect(response_data[:data][:card][:user][:id]).to eq(client.id)
        end
      end

      context "with invalid parameters" do
        before { put :update, params: { id: card.id, card: { product_id: nil } } }

        it_behaves_like :blank, "card", "product"
      end

      context "when card is not in issued state" do
        before { card.update!(state: "approved") }

        it_behaves_like :invalid_card_state do
          before { put :update, params: { id: card.id, card: { product_id: 1 } } }
        end
      end

      context "when card does not exist" do
        before { put :update, params: { id: -1, card: { product_id: 1 } } }

        it_behaves_like :not_found, "card"
      end
    end

    describe "when user is not logged in" do
      it_behaves_like :unauthorized do
        before { put :update, params: { id: card.id } }
      end
    end

    describe "when admin is logged in" do
      let(:admin) { create(:admin) }

      it_behaves_like :forbidden do
        before do
          login(user: admin)
          put :update, params: { id: card.id, card: { product_id: 1 } }
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:client) { create(:client) }
    let(:card) { create(:card, user: client) }

    describe "when client is logged in" do
      before { login(user: client) }

      context "when card exists" do
        before { delete :destroy, params: { id: card.id } }

        it "deletes the card" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:card][:id]).to eq(card.id)
          expect(Card.exists?(card.id)).to be_falsey
        end
      end

      context "when card does not exist" do
        before { delete :destroy, params: { id: -1 } }

        it_behaves_like :not_found, "card"
      end

      context "when card is not in issued state" do
        before { card.update!(state: "approved") }

        it_behaves_like :invalid_card_state do
          before { delete :destroy, params: { id: card.id } }
        end
      end
    end

    describe "when user is not logged in" do
      it_behaves_like :unauthorized do
        before { delete :destroy, params: { id: card.id } }
      end
    end

    describe "when admin is logged in" do
      let(:admin) { create(:admin) }

      it_behaves_like :forbidden do
        before do
          login(user: admin)
          delete :destroy, params: { id: card.id }
        end
      end
    end
  end

  describe "PATCH #rejected" do
    let(:client) { create(:client) }
    let(:card) { create(:card, user: client, state: "issued") }

    describe "when client is logged in" do
      before { login(user: client) }

      context "when card exists and is in issued state" do
        before { patch :rejected, params: { id: card.id } }

        it "rejects the card" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:card][:id]).to eq(card.id)
          expect(card.reload.state).to eq("rejected")
        end
      end

      context "when card does not exist" do
        before { patch :rejected, params: { id: -1 } }

        it_behaves_like :not_found, "card"
      end

      context "when card is not in issued state" do
        before { card.update!(state: "approved") }

        it_behaves_like :invalid_card_state do
          before { patch :rejected, params: { id: card.id } }
        end
      end
    end

    describe "when user is not logged in" do
      it_behaves_like :unauthorized do
        before { patch :rejected, params: { id: card.id } }
      end
    end

    describe "when admin is logged in" do
      let(:admin) { create(:admin) }

      it_behaves_like :forbidden do
        before do
          login(user: admin)
          patch :rejected, params: { id: card.id }
        end
      end
    end
  end

  describe "PATCH #activate_accessible_product" do
    let(:client) { create(:client) }
    let(:product) { create(:product) }
    let(:card) do
      create :card,
        user: client,
        product: product,
        state: "approved",
        pin_code: pin_code,
        activation_code: "valid_activation_code"
    end

    describe "when client is logged in" do
      before { login(user: client) }

      context "calls ActivateAccessibleProductService once" do
        context "with pin_code" do
          let(:pin_code) { "1234" }

          before do
            allow(Api::V1::Client::ActivateAccessibleProductService).to receive(:new).and_return(double(call: {}))
            patch :activate_accessible_product, params: {
              id: card.id,
              activation_code: "valid_activation_code",
              pin_code: pin_code
            }
          end

          it "calls the service exactly once with correct params" do
            expect(Api::V1::Client::ActivateAccessibleProductService).to have_received(:new).with(
              user: client,
              product: product,
              activation_code: "valid_activation_code",
              pin_code: pin_code
            ).once
          end
        end

        context "without pin_code" do
          let(:pin_code) { nil }

          before do
            allow(Api::V1::Client::ActivateAccessibleProductService).to receive(:new).and_return(double(call: {}))
            patch :activate_accessible_product, params: {
              id: card.id,
              activation_code: "valid_activation_code"
            }
          end

          it "calls the service exactly once with correct params" do
            expect(Api::V1::Client::ActivateAccessibleProductService).to have_received(:new).with(
              user: client,
              product: product,
              activation_code: "valid_activation_code",
              pin_code: pin_code
            ).once
          end
        end
      end

      context "when pin_code is missing" do
        let(:pin_code) { "1234" }

        before do
          allow(Api::V1::Client::ActivateAccessibleProductService).to receive(:new).and_return(double(call: {}))
          patch :activate_accessible_product, params: {
            id: card.id,
            activation_code: "invalid_activation_code",
          }
        end

        it_behaves_like :parameter_missing
      end

      context "when activation_code is missing" do
        let(:pin_code) { "1234" }

        before do
          allow(Api::V1::Client::ActivateAccessibleProductService).to receive(:new).and_return(double(call: {}))
          patch :activate_accessible_product, params: {
            id: card.id,
            pin_code: pin_code
          }
        end

        it_behaves_like :parameter_missing
      end

      context "when card does not exist" do
        before do
          patch :activate_accessible_product, params: {
            id: -1,
            activation_code: "valid_activation_code",
            pin_code: "1234"
          }
        end

        it_behaves_like :not_found, "card"
      end
    end

    describe "when user is not logged in" do
      let(:pin_code) { "1234" }

      it_behaves_like :unauthorized do
        before { patch :activate_accessible_product, params: { id: card.id } }
      end
    end

    describe "when admin is logged in" do
      let(:admin) { create(:admin) }
      let(:pin_code) { "1234" }

      it_behaves_like :forbidden do
        before do
          login(user: admin)
          patch :activate_accessible_product, params: { id: card.id }
        end
      end
    end
  end
end
