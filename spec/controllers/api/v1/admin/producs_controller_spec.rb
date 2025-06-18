# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Admin::ProductsController, type: :controller do
  describe "GET #index" do
    let(:admin) { create(:admin) }
    let(:brand) { create(:brand) }
    let(:products) { create_list(:product, 3, brand: brand) }

    describe "when admin is logged in" do
      context "when fetching all products" do
        before do
          products
          login(user: admin)
          get :index, params: { brand_id: brand.id }
        end

        it "returns a successful response" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:products].size).to eq(3)
          expect(response_data[:meta]).to have_key(:pagy_info)
        end
      end

      context "when filter by name is applied" do
        let!(:filtered_product) { create(:product, name: "Filtered Product", brand: brand) }

        before do
          products
          login(user: admin)
          get :index, params: { filter: { name: "Filtered Product" }, brand_id: brand.id }
        end

        it "returns only the filtered products" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:products].size).to eq(1)
          expect(response_data[:data][:products].first[:name]).to eq("Filtered Product")
        end
      end

      context "when sorting by name in descending order" do
        let!(:product_a) { create(:product, name: "Product A", brand: brand) }
        let!(:product_b) { create(:product, name: "Product B", brand: brand) }

        before do
          login(user: admin)
          get :index, params: { sort: { name: :desc }, brand_id: brand.id }
        end

        it "returns products sorted by name in descending order" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:products].map { |p| p[:name] }).to eq(["Product B", "Product A"])
        end
      end
    end

    describe "when user is not logged in" do
      it_behaves_like :unauthorized do
        before { get :index, params: { brand_id: brand.id } }
      end
    end

    describe "when client is logged in" do
      let(:client) { create(:client) }

      it_behaves_like :forbidden do
        before do
          login(user: client)
          get :index, params: { brand_id: brand.id }
        end
      end
    end
  end

  describe "GET #show" do
    let(:admin) { create(:admin) }
    let(:brand) { create(:brand) }
    let(:product) { create(:product, brand: brand) }

    describe "when admin is logged in" do
      before { login(user: admin) }

      context "when product exists" do
        before { get :show, params: { id: product.id, brand_id: brand.id } }

        it "returns a successful response" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:product][:id]).to eq(product.id)
          expect(response_data[:data][:product][:name]).to eq(product.name)
        end
      end

      context "when product does not exist" do
        before { get :show, params: { id: "nonexistent", brand_id: brand.id } }

        it_behaves_like :not_found, "product"
      end

      context "when brand does not exist" do
        before { get :show, params: { id: product.id, brand_id: "nonexistent" } }

        it_behaves_like :not_found, "brand"
      end
    end

    describe "when user is not logged in" do
      it_behaves_like :unauthorized do
        before { get :show, params: { id: product.id, brand_id: brand.id } }
      end
    end

    describe "when client is logged in" do
      let(:client) { create(:client) }

      it_behaves_like :forbidden do
        before do
          login(user: client)
          get :show, params: { id: product.id, brand_id: brand.id }
        end
      end
    end
  end

  describe "POST #create" do
    let(:admin) { create(:admin) }
    let(:brand) { create(:brand) }
    let(:product_params) do
      {
        name: name,
        description: description,
        price: price,
        state: state,
      }
    end

    context "when admin is logged in" do
      before do
        login(user: admin)
        post :create, params: { product: product_params, brand_id: brand_id }
      end

      context "with valid parameters" do
        let(:name) { "New Product" }
        let(:description) { "Product Description" }
        let(:price) { 100.0 }
        let(:state) { "active" }
        let(:brand_id) { brand.id }

        it "creates a new product and returns a successful response" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:success]).to be true
          expect(response_data[:data][:product][:name]).to eq "New Product"
          expect(response_data[:data][:product][:description]).to eq "Product Description"
          expect(response_data[:data][:product][:state]).to eq "active"
        end
      end

      context "with invalid parameters" do
        let(:name) { "" }
        let(:description) { "" }
        let(:price) { nil }
        let(:state) { "" }
        let(:brand_id) { brand.id }

        it_behaves_like :blank, "product", "name"
      end

      context "when brand not found" do
        let(:name) { "New Product" }
        let(:description) { "Product Description" }
        let(:price) { 100.0 }
        let(:state) { "active" }
        let(:brand_id) { "nonexistent" }

        it_behaves_like :not_found, "brand"
      end

      context "when price is invalid" do
        let(:name) { "New Product" }
        let(:description) { "Product Description" }
        let(:price) { -10.0 }
        let(:state) { "active" }
        let(:brand_id) { brand.id }

        it_behaves_like :greater_than, "product", "price"
      end
    end

    context "when user is not logged in" do
      let(:name) { "New Product" }
      let(:description) { "Product Description" }
      let(:price) { 100.0 }
      let(:state) { "active" }
      let(:brand_id) { brand.id }

      it_behaves_like :unauthorized do
        before { post :create, params: { product: product_params, brand_id: brand_id } }
      end
    end

    context "when client is logged in" do
      let(:name) { "New Product" }
      let(:description) { "Product Description" }
      let(:price) { 100.0 }
      let(:state) { "active" }
      let(:brand_id) { brand.id }
      let(:client) { create(:client) }

      it_behaves_like :forbidden do
        before do
          login(user: client)
          post :create, params: { product: product_params, brand_id: brand_id }
        end
      end
    end
  end

  describe "PUT #update" do
    let(:admin) { create(:admin) }
    let(:brand) { create(:brand) }
    let(:product) { create(:product, brand: brand) }
    let(:product_params) do
      {
        name: name,
        description: description,
        price: price,
        state: state
      }
    end

    context "when admin is logged in" do
      before do
        login(user: admin)
        put :update, params: { id: product_id, product: product_params, brand_id: brand_id }
      end

      context "with valid parameters" do
        let(:name) { "Updated Product" }
        let(:description) { "Updated Description" }
        let(:price) { 200.0 }
        let(:state) { "inactive" }
        let(:brand_id) { brand.id }
        let(:product_id) { product.id }

        it "updates the product and returns a successful response" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:success]).to be true
          expect(response_data[:data][:product][:name]).to eq "Updated Product"
          expect(response_data[:data][:product][:description]).to eq "Updated Description"
          expect(response_data[:data][:product][:state]).to eq "inactive"
        end
      end

      context "with invalid parameters" do
        let(:name) { "" }
        let(:description) { "" }
        let(:price) { nil }
        let(:state) { "" }
        let(:brand_id) { brand.id }
        let(:product_id) { product.id }

        it_behaves_like :blank, "product", "name"
      end

      context "when brand not found" do
        let(:name) { "Updated Product" }
        let(:description) { "Updated Description" }
        let(:price) { 200.0 }
        let(:state) { "inactive" }
        let(:brand_id) { "nonexistent" }
        let(:product_id) { product.id }

        it_behaves_like :not_found, "brand"
      end

      context "when product not found" do
        let(:name) { "Updated Product" }
        let(:description) { "Updated Description" }
        let(:price) { 200.0 }
        let(:state) { "inactive" }
        let(:brand_id) { brand.id }
        let(:product_id) { "nonexistent" }

        it_behaves_like :not_found, "product"
      end

      context "when price is invalid" do
        let(:name) { "Updated Product" }
        let(:description) { "Updated Description" }
        let(:price) { -50.0 }
        let(:state) { "inactive" }
        let(:brand_id) { brand.id }
        let(:product_id) { product.id }

        it_behaves_like :greater_than, "product", "price"
      end
    end

    context "when user is not logged in" do
      let(:name) { "Updated Product" }
      let(:description) { "Updated Description" }
      let(:price) { 200.0 }
      let(:state) { "inactive" }
      let(:brand_id) { brand.id }

      it_behaves_like :unauthorized do
        before { put :update, params: { id: product.id, product: product_params, brand_id: brand_id } }
      end
    end

    context "when client is logged in" do
      let(:name) { "Updated Product" }
      let(:description) { "Updated Description" }
      let(:price) { 200.0 }
      let(:state) { "inactive" }
      let(:brand_id) { brand.id }
      let(:client) { create(:client) }

      it_behaves_like :forbidden do
        before do
          login(user: client)
          put :update, params: { id: product.id, product: product_params, brand_id: brand_id }
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:admin) { create(:admin) }
    let(:brand) { create(:brand) }
    let(:product) { create(:product, brand: brand) }

    context "when admin is logged in" do
      before { login(user: admin) }

      context "when product exists" do
        before { delete :destroy, params: { id: product.id, brand_id: brand.id } }

        it "deletes the product and returns a successful response" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:success]).to be true
          expect(response_data[:data]).to eq({})
          expect(response_data[:meta]).to eq({})
        end
      end

      context "when product does not exist" do
        before { delete :destroy, params: { id: "nonexistent", brand_id: brand.id } }

        it_behaves_like :not_found, "product"
      end

      context "when brand does not exist" do
        before { delete :destroy, params: { id: product.id, brand_id: "nonexistent" } }

        it_behaves_like :not_found, "brand"
      end
    end

    context "when user is not logged in" do
      it_behaves_like :unauthorized do
        before { delete :destroy, params: { id: product.id, brand_id: brand.id } }
      end
    end

    context "when client is logged in" do
      let(:client) { create(:client) }

      it_behaves_like :forbidden do
        before do
          login(user: client)
          delete :destroy, params: { id: product.id, brand_id: brand.id }
        end
      end
    end
  end
end
