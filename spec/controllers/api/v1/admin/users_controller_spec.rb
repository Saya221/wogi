# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Admin::UsersController, type: :controller do
  describe "GET #index" do
    let(:admin) { create(:admin, name: "User C") }
    let(:users) { create_list(:user, 3) }

    describe "when admin is logged in" do
      context "when fetching all users" do
        before do
          users
          login(user: admin)
          get :index
        end

        it "returns a successful response" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:users].size).to eq(4)
          expect(response_data[:meta]).to have_key(:pagy_info)
        end
      end

      context "when filter by name is applied" do
        let!(:filtered_user) { create(:user, name: "Filtered User") }

        before do
          users
          login(user: admin)
          get :index, params: { filter: { name: "Filtered User" } }
        end

        it "returns only the filtered users" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:users].size).to eq(1)
          expect(response_data[:data][:users].first[:name]).to eq("Filtered User")
        end
      end

      context "when sorting by name in descending order" do
        let!(:user_a) { create(:user, name: "User A") }
        let!(:user_b) { create(:user, name: "User B") }

        before do
          login(user: admin)
          get :index, params: { sort: { name: :desc } }
        end

        it "returns users sorted by name in descending order" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:users].map { |u| u[:name] }).to eq(["User C", "User B", "User A"])
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
    let(:user) { create(:user) }

    describe "when admin is logged in" do
      before { login(user: admin) }

      context "when user exists" do
        before { get :show, params: { id: user.id } }

        it "returns a successful response" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:data][:user][:id]).to eq(user.id)
          expect(response_data[:data][:user][:name]).to eq(user.name)
        end
      end

      context "when user does not exist" do
        before { get :show, params: { id: "nonexistent" } }

        it_behaves_like :not_found, "user"
      end
    end

    describe "when user is not logged in" do
      it_behaves_like :unauthorized do
        before { get :show, params: { id: user.id } }
      end
    end

    describe "when client is logged in" do
      let(:client) { create(:client) }

      it_behaves_like :forbidden do
        before do
          login(user: client)
          get :show, params: { id: user.id }
        end
      end
    end
  end

  describe "POST #create" do
    let(:admin) { create(:admin) }
    let(:user_params) do
      {
        name:,
        email:,
        password:,
        payout_rate:
      }
    end

    context "when admin is logged in" do
      context "with valid parameters" do
        let(:name) { "New User" }
        let(:email) { "user@example.com" }
        let(:password) { "Password123!" }
        let(:payout_rate) { 0.85 }

        before do
          login(user: admin)
          post :create, params: { user: user_params }
        end

        it "creates a new user and returns a successful response" do
          expect(response).to have_http_status(:ok)
          expect(response_data[:success]).to be true
          expect(response_data[:data][:client][:name]).to eq "New User"
          expect(response_data[:data][:client][:email]).to eq "user@example.com"
          expect(response_data[:data][:client][:payout_rate]).to eq 0.85
        end
      end

      context "when email is invalid" do
        let(:name) { "" }
        let(:email) { "" }
        let(:password) { "" }
        let(:payout_rate) { "" }

        before do
          login(user: admin)
          post :create, params: { user: user_params }
        end

        it_behaves_like :invalid, "client", "email"
      end

      context "when email is already taken" do
        let(:name) { "New User" }
        let(:email) { "user@example.com" }
        let(:password) { "Password123!" }
        let(:payout_rate) { 0.85 }
        let!(:existing_user) { create(:client, email:) }

        before do
          login(user: admin)
          post :create, params: { user: user_params }
        end

        it_behaves_like :taken, "client", "email"
      end

      context "when password is invalid" do
        let(:name) { "" }
        let(:email) { "user@example.com" }
        let(:password) { "" }
        let(:payout_rate) { 0.85 }

        before do
          login(user: admin)
          post :create, params: { user: user_params }
        end

        it_behaves_like :wrong_format, "client", "password"
      end

      context "when payout rate is not a valid number" do
        let(:name) { "New User" }
        let(:email) { "user@example.com" }
        let(:password) { "Password123!" }
        let(:payout_rate) { "invalid" }

        before do
          login(user: admin)
          post :create, params: { user: user_params }
        end

        it_behaves_like :not_a_number, "client", "payout_rate"
      end

      context "when payout rate is less than 0" do
        let(:name) { "New User" }
        let(:email) { "user@example.com" }
        let(:password) { "Password123!" }
        let(:payout_rate) { -0.1 }

        before do
          login(user: admin)
          post :create, params: { user: user_params }
        end

        it_behaves_like :greater_than, "client", "payout_rate"
      end

      context "when payout rate is greater than 100" do
        let(:name) { "New User" }
        let(:email) { "user@example.com" }
        let(:password) { "Password123!" }
        let(:payout_rate) { 101 }

        before do
          login(user: admin)
          post :create, params: { user: user_params }
        end

        it_behaves_like :less_than, "client", "payout_rate"
      end
    end

    context "when user is not logged in" do
      let(:name) { "New User" }
      let(:email) { "user@example.com" }
      let(:password) { "Password123!" }
      let(:payout_rate) { 0.85 }

      it_behaves_like :unauthorized do
        before { post :create, params: { user: user_params } }
      end
    end

    context "when client is logged in" do
      let(:name) { "New User" }
      let(:email) { "user@example.com" }
      let(:password) { "Password123!" }
      let(:payout_rate) { 0.85 }
      let(:client) { create(:client) }

      it_behaves_like :forbidden do
        before do
          login(user: client)
          post :create, params: { user: user_params }
        end
      end
    end
  end
end
