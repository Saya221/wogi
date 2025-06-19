# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Admin::ReportsController, type: :controller do
  describe "GET #index" do
    let(:brand) { create(:brand) }
    let(:client) { create(:client) }

    context "when user is an admin" do
      let(:admin) { create(:admin) }

      before { login(user: admin) }

      context "when parameters are valid" do
        before do
          allow(Api::V1::Admin::ReportsService).to receive(:new).and_return(double(call: {}))
          get :index, params: { brand_id: brand.id, client_id: client.id }
        end

        it "calls the ReportsService with the correct parameters" do
          expect(Api::V1::Admin::ReportsService).to have_received(:new).with(brand: brand, client: client).once
        end
      end

      context "when parameters are missing" do
        before { get :index, params: {} }

        it_behaves_like :parameter_missing
      end

      context "when brand not found" do
        before { get :index, params: { brand_id: 0, client_id: client.id } }

        it_behaves_like :not_found, "brand"
      end

      context "when client not found" do
        before { get :index, params: { brand_id: brand.id, client_id: 0 } }

        it_behaves_like :not_found, "client"
      end
    end

    context "when user is not logged in" do
      it_behaves_like :unauthorized do
        before { get :index, params: { brand_id: brand.id, client_id: client.id } }
      end
    end

    context "when user is a client" do
      it_behaves_like :forbidden do
        before do
          login(user: client)
          get :index, params: { brand_id: brand.id, client_id: client.id }
        end
      end
    end
  end
end
