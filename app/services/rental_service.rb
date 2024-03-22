class RentalService
  include ActiveModel::Validations

  TTL = 3600 # 1 hour
  START_RENTAL_KEY = 'start_rental'.freeze
  END_RENTAL_KEY = 'end_rental'.freeze

  validates :user, :car, presence: true

  def initialize(car:, user:)
    @car = car
    @user = user
    @client = RedisService.client
    @redis_key = "#{car.id}:#{user.id}"
    @rental_data = @client.hgetall(@redis_key)
  end

  def start_rental
    return unless valid?
    return Rails.logger.warn "Rental already exists ID:#{rental_data['rental_id']}" if data_key? START_RENTAL_KEY

    check_car
    check_user

    return if errors.any?

    perform_rental_operation { create_rental }
  end

  def end_rental
    return unless valid?
    return Rails.logger.warn "Rental already removed ID:#{rental_data['rental_id']}" if data_key? END_RENTAL_KEY

    check_rental

    return if errors.any?

    perform_rental_operation { destroy_rental }
  end

  def rental
    @rental ||= Rental.find_by(car: car, user: user)
  end

  private

  attr_reader :car, :user, :client, :redis_key, :rental_data

  def perform_rental_operation(&operation)
    ActiveRecord::Base.transaction { operation.call }
  rescue Redis::CommandError, ActiveRecord::RecordInvalid => e
    message = "Error: #{e.message}"
    Rails.logger.error message
    errors.add(:base, message)
    false
  end

  def create_rental
    @rental = Rental.create(car: car, user: user)
    rental.car.rented!
    write_rental_data_to_redis(START_RENTAL_KEY)
  end

  def destroy_rental
    rental.destroy
    rental.car.available!
    write_rental_data_to_redis(END_RENTAL_KEY)
  end

  def write_rental_data_to_redis(operation_key)
    client.multi do |multi|
      multi.hmset(redis_key, 'rental_id', rental.id.to_s, 'key', operation_key)
      multi.expire(redis_key, TTL)
    end
  end

  def data_key?(operation_key)
    rental_data['key'] == operation_key
  end

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
