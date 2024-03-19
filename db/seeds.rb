# Создаем 100 пользователей
100.times do
  User.create!(name: Faker::Name.name)
end

# Создаем 100 автомобилей
100.times do
  Car.create!(name: Faker::Vehicle.make_and_model)
end

# Создаем аренду для 30% пользователей и автомобилей
users = User.all.sample((User.count * 0.3).to_i)
cars = Car.all.sample((Car.count * 0.3).to_i)

users.zip(cars).each { |user, car| Rental.create!(car:, user:) }
