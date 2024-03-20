class RentalService
  include ActiveModel::Validations

  validates :user, :car, presence: true

  def initialize(car:, user:)
    @car = car
    @user = user
  end

  def start_rental
    return unless valid?
    return Rails.logger.warn "Rental already exists for user ID:#{user.id} and car ID:#{car.id}" if rental.present?

    check_car
    check_user

    return if errors.any?

    ActiveRecord::Base.transaction do
      @rental = Rental.create(car: car, user: user)
      rental.car.rented!
    end
  end

  def end_rental
    return unless valid?

    check_rental

    return if errors.any?

    ActiveRecord::Base.transaction do
      rental.destroy
      rental.car.available!
    end
  end

  def rental
    @rental ||= Rental.find_by(car: car, user: user)
  end

  private

  attr_reader :car, :user

  def check_car
    errors.add(:car, 'is not available') unless car.available?
  end

  def check_user
    errors.add(:user, 'there are open rentals') if user.rental.present?
  end

  def check_rental
    errors.add(:rental, 'not exists') unless rental.present?
  end
end
