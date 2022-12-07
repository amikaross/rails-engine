Rails.application.routes.draw do

  get "/api/v1/items/find", to: "api/v1/items/search#show"

  namespace :api do 
    namespace :v1 do
      resources :merchants, only: [:index, :show] do 
        resources :items, only: [:index]
      end

      resources :items do 
        resource :merchant, only: [:show], controller: :merchants
      end
    end
  end
end
