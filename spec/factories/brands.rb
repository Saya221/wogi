# frozen_string_literal: true

FactoryBot.define do
  factory :brand do
    name { "#{Time.current.to_i} - #{Faker::Company.unique.name}" }
    state { :active }
    description { Faker::Company.catch_phrase }
    country { Faker::Address.country }
    website_url { Faker::Internet.url }
  end
end
