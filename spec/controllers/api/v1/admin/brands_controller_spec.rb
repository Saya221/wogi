# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Admin::BrandsController, type: :controller do
  describe "GET #index" do
    let(:admin) { create(:admin) }
    let(:brands) { create_list(:brand, 3) }

    describe "when admin is logged in" do
      context "when fetching all brands" do
        before do
          brands
          login(user: admin)
          get :index
        end

        it "returns a successful response" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:brands].size).to eq(3)
          expect(response_data[:meta]).to have_key(:pagy_info)
        end
      end

      context "when filter by name is applied" do
        let!(:filtered_brand) { create(:brand, name: "Filtered Brand") }

        before do
          brands
          login(user: admin)
          get :index, params: { filter: { name: "Filtered Brand" } }
        end

        it "returns only the filtered brands" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:brands].size).to eq(1)
          expect(response_data[:data][:brands].first[:name]).to eq("Filtered Brand")
        end
      end

      context "when sorting by name in descending order" do
        let!(:brand_a) { create(:brand, name: "Brand A") }
        let!(:brand_b) { create(:brand, name: "Brand B") }

        before do
          login(user: admin)
          get :index, params: { sort: { name: :desc } }
        end

        it "returns brands sorted by name in descending order" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:brands].map { |b| b[:name] }).to eq(["Brand B", "Brand A"])
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

  describe "GET #show" do
    let(:admin) { create(:admin) }
    let(:brand) { create(:brand) }

    describe "when admin is logged in" do
      before { login(user: admin) }

      context "when brand exists" do
        before { get :show, params: { id: brand.id } }

        it "returns a successful response" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:brand][:id]).to eq(brand.id)
          expect(response_data[:data][:brand][:name]).to eq(brand.name)
        end
      end

      context "when brand does not exist" do
        before { get :show, params: { id: "nonexistent" } }

        it_behaves_like :not_found, "brand"
      end
    end

    describe "when user is not logged in" do
      it_behaves_like :unauthorized do
        before { get :show, params: { id: brand.id } }
      end
    end

    describe "when client is logged in" do
      let(:client) { create(:client) }

      it_behaves_like :forbidden do
        before do
          login(user: client)
          get :show, params: { id: brand.id }
        end
      end
    end
  end

  describe "POST #create" do
    let(:admin) { create(:admin) }
    let(:brand_params) do
      {
        name: name,
        description: description,
        country: country,
        state: state,
        website_url: website_url
      }
    end

    context "when admin is logged in" do
      before do
        login(user: admin)
        post :create, params: { brand: brand_params }
      end

      context "with valid parameters" do
        let(:name) { "New Brand" }
        let(:description) { "Brand Description" }
        let(:country) { "USA" }
        let(:state) { "active" }
        let(:website_url) { "https://example.com" }

        it "creates a new brand and returns a successful response" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:success]).to be true
          expect(response_data[:data][:brand][:name]).to eq "New Brand"
          expect(response_data[:data][:brand][:description]).to eq "Brand Description"
          expect(response_data[:data][:brand][:state]).to eq "active"
        end
      end

      context "with invalid parameters" do
        let(:name) { "" }
        let(:description) { "" }
        let(:country) { "" }
        let(:state) { "" }
        let(:website_url) { "" }

        it_behaves_like :blank, "brand", "name"
      end
    end

    context "when user is not logged in" do
      let(:name) { "New Brand" }
      let(:description) { "Brand Description" }
      let(:country) { "USA" }
      let(:state) { "active" }
      let(:website_url) { "https://example.com" }

      it_behaves_like :unauthorized do
        before { post :create, params: { brand: brand_params } }
      end
    end

    context "when client is logged in" do
      let(:name) { "New Brand" }
      let(:description) { "Brand Description" }
      let(:country) { "USA" }
      let(:state) { "active" }
      let(:website_url) { "https://example.com" }
      let(:client) { create(:client) }

      it_behaves_like :forbidden do
        before do
          login(user: client)
          post :create, params: { brand: brand_params }
        end
      end
    end
  end

  describe "PUT #update" do
    let(:admin) { create(:admin) }
    let(:brand) { create(:brand) }
    let(:brand_params) do
      {
        name: name,
        description: description,
        country: country,
        state: state,
        website_url: website_url
      }
    end

    context "when admin is logged in" do
      before { login(user: admin) }

      context "with valid parameters" do
        let(:name) { "Updated Brand" }
        let(:description) { "Updated Description" }
        let(:country) { "Canada" }
        let(:state) { "inactive" }
        let(:website_url) { "https://updated-example.com" }

        before { put :update, params: { id: brand.id, brand: brand_params } }

        it "updates the brand and returns a successful response" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:success]).to be true
          expect(response_data[:data][:brand][:name]).to eq "Updated Brand"
          expect(response_data[:data][:brand][:description]).to eq "Updated Description"
          expect(response_data[:data][:brand][:state]).to eq "inactive"
        end
      end

      context "with invalid parameters" do
        let(:name) { "" }
        let(:description) { "" }
        let(:country) { "" }
        let(:state) { "" }
        let(:website_url) { "" }

        before { put :update, params: { id: brand.id, brand: brand_params } }

        it_behaves_like :blank, "brand", "name"
      end
    end

    context "when user is not logged in" do
      let(:name) { "Updated Brand" }
      let(:description) { "Updated Description" }
      let(:country) { "Canada" }
      let(:state) { "inactive" }
      let(:website_url) { "https://updated-example.com" }

      it_behaves_like :unauthorized do
        before { put :update, params: { id: brand.id, brand: brand_params } }
      end
    end

    context "when client is logged in" do
      let(:name) { "Updated Brand" }
      let(:description) { "Updated Description" }
      let(:country) { "Canada" }
      let(:state) { "inactive" }
      let(:website_url) { "https://updated-example.com" }
      let(:client) { create(:client) }

      it_behaves_like :forbidden do
        before do
          login(user: client)
          put :update, params: { id: brand.id, brand: brand_params }
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:admin) { create(:admin) }
    let(:brand) { create(:brand) }

    context "when admin is logged in" do
      before { login(user: admin) }

      context "when brand exists" do
        before { delete :destroy, params: { id: brand.id } }

        it "deletes the brand and returns a successful response" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:success]).to be true
          expect(response_data[:data]).to eq({})
          expect(response_data[:meta]).to eq({})
        end
      end

      context "when brand does not exist" do
        before { delete :destroy, params: { id: "nonexistent" } }

        it_behaves_like :not_found, "brand"
      end
    end

    context "when user is not logged in" do
      it_behaves_like :unauthorized do
        before { delete :destroy, params: { id: brand.id } }
      end
    end

    context "when client is logged in" do
      let(:client) { create(:client) }

      it_behaves_like :forbidden do
        before do
          login(user: client)
          delete :destroy, params: { id: brand.id }
        end
      end
    end
  end
end
