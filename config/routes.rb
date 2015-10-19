Rails.application.routes.draw do
  resources :clients, only: [:index, :show]

  root 'clients#index'
end
