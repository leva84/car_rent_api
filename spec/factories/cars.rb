FactoryBot.define do
  factory :car do
    name { Faker::Vehicle.make_and_model }
  end
end
