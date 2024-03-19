class Car < ApplicationRecord
  has_one :rental
  has_one :user, through: :rental

  validates :name, length: { minimum: 2, maximum: 150 }, presence: true

  enum status: { available: 0, rented: 1, maintenance: 2 }
end
