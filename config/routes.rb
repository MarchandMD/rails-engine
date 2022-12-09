Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get "/api/v1/merchants/find", to: "api/v1/merchants/search#show"
  get "/api/v1/items/find_all", to: "api/v1/items/search#index"

  namespace :api do
    namespace :v1 do
      resources :merchants, only: %i[index show] do
        resources :items, only: %i[index show]
      end
      resources :items
    end
  end

  get '/api/v1/items/:item_id/merchant', to: 'api/v1/merchants#show'
end
