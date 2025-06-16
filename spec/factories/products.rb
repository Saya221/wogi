# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    state { :active }
    brand
    description { Faker::Lorem.sentence }
    price { Faker::Commerce.price(range: 10.0..100.0) }
  end
end
