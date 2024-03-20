class RentalSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at

  belongs_to :car
  belongs_to :user
end
