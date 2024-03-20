class RentalsController < ApplicationController
  before_action :service

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

  def user
    @user ||= User.find_by(id: params[:user_id])
  end

  def car
    @car ||= Car.find_by(id: params[:car_id])
  end

  def service
    @service ||= RentalService.new(car: car, user: user)
  end
end
