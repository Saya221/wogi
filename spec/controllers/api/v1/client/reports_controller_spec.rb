# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Client::ReportsController, type: :controller do
  describe "GET #index" do
    context "when user is a client" do
      let(:client) { create(:client) }

      before { login(user: client) }

      context "when parameters are valid" do
        before do
          allow(Api::V1::Client::ReportsService).to receive(:new).and_return(double(call: {}))
          get :index
        end

        it "calls the ReportsService with the correct parameters" do
          expect(Api::V1::Client::ReportsService).to have_received(:new).with(client:).once
        end
      end
    end

    context "when user is not logged in" do
      it_behaves_like :unauthorized do
        before { get :index }
      end
    end

    context "when user is an admin" do
      let(:admin) { create(:admin) }

      it_behaves_like :forbidden do
        before do
          login(user: admin)
          get :index
        end
      end
    end
  end
end
