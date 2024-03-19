class User < ApplicationRecord
  has_one :rental
  has_one :car, through: :rental

  validates :name, length: { minimum: 2, maximum: 150 }, presence: true
end
