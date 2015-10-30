Rails.application.routes.draw do
  resources :clients, only: [:index, :show]
  resources :hosts, only: [:new, :create, :show, :edit, :update, :destroy] do
    resources :jobs, only: [:new, :create, :show, :edit, :update, :destroy]
  end

  root 'clients#index'
end
