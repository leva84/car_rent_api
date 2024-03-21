class RentalService
  include ActiveModel::Validations

  TTL = 6000 # 1 hour
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
    return Rails.logger.warn "Rental already exists ID:#{rental.id}" if rental.present?

    check_car
    check_user

    return if errors.any?

    ActiveRecord::Base.transaction do
      @rental = Rental.create(car: car, user: user)
      rental.car.rented!
    end

    write_rental_data_to_redis(START_RENTAL_KEY)
  end

  def end_rental
    return unless valid?

    if rental_data['key'] == END_RENTAL_KEY
      Rails.logger.warn "Rental already removed ID:#{rental_data['rental_id']}"
      return true
    end

    check_rental

    return if errors.any?

    ActiveRecord::Base.transaction do
      rental.destroy
      rental.car.available!
    end

    write_rental_data_to_redis(END_RENTAL_KEY)
  end

  def rental
    @rental ||= Rental.find_by(car: car, user: user)
  end

  private

  attr_reader :car, :user, :client, :redis_key, :rental_data

  def write_rental_data_to_redis(operation_key)
    client.multi do |client|
      client.hmset(redis_key, 'rental_id', rental.id.to_s, 'key', operation_key)
      client.expire(redis_key, TTL)
    end
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
