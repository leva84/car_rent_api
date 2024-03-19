module Naming
  extend ActiveSupport::Concern

  MIN_NAME_LENGTH = 2
  MAX_NAME_LENGTH = 150

  included do
    validates :name, length: { minimum: MIN_NAME_LENGTH, maximum: MAX_NAME_LENGTH }, presence: true
  end
end
