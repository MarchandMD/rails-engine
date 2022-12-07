FactoryBot.define do
  factory :item do
    name { Faker::Company.name }
    description { Faker::Quote.yoda }
    unit_price { Faker::Number.decimal(l_digits:2) }
    merchant_id { Faker::Number.between(from: 1, to: 20)}
  end
end