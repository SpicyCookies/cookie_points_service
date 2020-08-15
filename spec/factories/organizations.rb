# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    id { Faker::Number.number(digits: 3) }
    name { Faker::Company.name }
    total_members { Faker::Number.number(digits: 3) }
    description { Faker::Lorem.sentence }
  end
end
