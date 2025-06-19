# frozen_string_literal: true

FactoryBot.define do
  factory :card do
    user { association :client }
    product
    state { :issued }
    activation_code { SecureRandom.hex(Settings.limit.activation_code).upcase }
    pin_code { "1234" }
  end
end
