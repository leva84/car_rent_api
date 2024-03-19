class Rental < ApplicationRecord
  belongs_to :car
  belongs_to :user

  validates :car, :user, presence: true
end
