# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserSession, type: :model do
  it_behaves_like :concerns

  describe "relationships" do
    it { is_expected.to belong_to(:user) }
  end

  describe "methods" do
    context "#gen_uniq_session_token" do
      # TODO: Find the way to test regression methods
    end
  end

  describe "instance methods" do
    it_behaves_like :filter_and_sort
  end
end
