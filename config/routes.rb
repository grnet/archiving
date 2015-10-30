Rails.application.routes.draw do
  resources :clients, only: [:index, :show]
  resources :hosts, only: [:new, :create, :show, :edit, :update, :destroy]

  resources :jobs, only: [:new, :create, :show, :edit, :update, :destroy]

  root 'clients#index'
end
