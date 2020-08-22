# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    organization_id { 1 }
    name { Faker::Esport.event }
    description { Faker::Lorem.sentence }
    start_time { DateTime.now.utc.iso8601 }
    end_time { (DateTime.now + 1).utc.iso8601 }
  end
end
