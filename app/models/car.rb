class Car < ApplicationRecord
  include Naming

  STATUSES = [
    AVAILABLE = 0,
    RENTED = 1,
    MAINTENANCE = 2
  ].freeze

  has_one :rental
  has_one :user, through: :rental

  enum status: { available: AVAILABLE, rented: RENTED, maintenance: MAINTENANCE }
end
