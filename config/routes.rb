Rails.application.routes.draw do
  resources :parsers, only: [:index] do
    collection do
      get :details
    end
  end
end
