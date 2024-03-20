class ErrorSerializer < ActiveModel::Serializer
  attributes :errors

  def errors
    object.errors.full_messages
  end
end
