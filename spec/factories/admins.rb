# frozen_string_literal: true

FactoryBot.define do
  factory :admin, parent: :user, class: "Admin" do
    type { "Admin" }
  end
end
