class Car < ApplicationRecord
  include Naming

  has_one :rental
  has_one :user, through: :rental

  enum status: { available: 0, rented: 1, maintenance: 2 }
end
