# frozen_string_literal: true

require "rails_helper"

RSpec.describe AccessibleProduct, type: :model do
  it_behaves_like :concerns

  describe "relationships" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:product) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:product_id).scoped_to(:user_id).ignoring_case_sensitivity }
  end

  describe "instance methods" do
    it_behaves_like :filter_and_sort
  end
end
