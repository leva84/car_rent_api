Rails.application.routes.draw do
  post 'start_rental', to: 'rentals#start_rental'
  post 'end_rental', to: 'rentals#end_rental'
end
