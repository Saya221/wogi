# frozen_string_literal: true

FactoryBot.define do
  factory :client, parent: :user, class: 'Client' do
    type { 'Client' }
    payout_rate { 10.0 }
  end
end
