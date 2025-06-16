FactoryBot.define do
  factory :brand do
    name { Faker::Company.unique.name }
    state { :active }
    description { Faker::Company.catch_phrase }
    country { Faker::Address.country }
    website_url { Faker::Internet.url }
  end
end
