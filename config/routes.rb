Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :merchants, only: %i[index show] do
        resources :items, only: %i[index show]
      end
      resources :items do
        resources :merchant, only: %i[index]
      end
    end
  end
end
