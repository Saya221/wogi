# frozen_string_literal: true

require "rails_helper"

RSpec.describe Card, type: :model do
  it_behaves_like :concerns

  describe "relationships" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:product) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:state).with_values(issued: 0, approved: 1, rejected: 2) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:activation_code).allow_blank }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:product_id).ignoring_case_sensitivity }
  end

  describe "methods" do
    context "#generate_activation_code" do
      # TODO: Find the way to test regression methods
    end
  end

  describe "instance methods" do
    it_behaves_like :filter_and_sort
  end
end
