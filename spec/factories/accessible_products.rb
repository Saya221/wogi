# frozen_string_literal: true

FactoryBot.define do
  factory :accessible_product do
    user
    product
    state { "inactive" }
  end
end
