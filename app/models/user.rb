class User < ApplicationRecord
  include Naming

  has_one :rental
  has_one :car, through: :rental
end
