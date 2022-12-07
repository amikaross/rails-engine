FactoryBot.define do
  factory :invoice do
    status{ Faker::Books::CultureSeries.planet }
    association :merchant
    association :customer
  end
end
