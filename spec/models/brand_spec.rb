# frozen_string_literal: true

require "rails_helper"

RSpec.describe Brand, type: :model do
  it_behaves_like :concerns

  describe "relationships" do
    it { is_expected.to have_many(:products).dependent(:destroy) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:state).with_values(inactive: 0, active: 1) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    subject { build(:brand, name: "UniqueBrand") }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end

  describe "instance methods" do
    it_behaves_like :filter_and_sort
  end
end
