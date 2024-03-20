class Rental < ApplicationRecord
  belongs_to :car
  belongs_to :user

  validates :car, :user, presence: true

  around_create :set_car_to_rented

  private

  def set_car_to_rented
    ActiveRecord::Base.transaction do
      yield
      car.rented!
    end
  end
end
