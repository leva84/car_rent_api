class RentalsController < ApplicationController
  attr_reader :user, :car, :service

  before_action :set_car, :set_user, :set_service

  def start_rental
    if service.start_rental
      render json: service.rental, serializer: RentalSerializer, status: :ok
    else
      render json: service, serializer: ErrorSerializer, status: :unprocessable_entity
    end
  end

  def end_rental
    if service.end_rental
      render json: { status: :ok }, status: :ok
    else
      render json: service, serializer: ErrorSerializer, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user ||= User.find_by(id: params[:user_id])
  end

  def set_car
    @car ||= Car.find_by(id: params[:car_id])
  end

  def set_service
    @service ||= RentalService.new(car: car, user: user)
  end
end
