# frozen_string_literal: true

FactoryBot.define do
  factory :membership do
    user_id { 1 }
    organization_id { 1 }
  end
end
