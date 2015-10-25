Rails.application.routes.draw do
  resources :clients, only: [:index, :show]
  resources :hosts, only: [:new, :create]

  root 'clients#index'
end
