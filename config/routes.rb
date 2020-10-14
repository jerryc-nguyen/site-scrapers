Rails.application.routes.draw do
  resources :parsers, only: [:index]
end
