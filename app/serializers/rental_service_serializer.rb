class RentalServiceSerializer < ActiveModel::Serializer
  attributes :rental, :user, :car

  def rental
    object.rental
  end

  def user
    object.user
  end

  def car
    object.car
  end
end
