Rails.application.routes.draw do
  resources :clients, only: [:index, :show]

  resources :hosts, only: [:new, :create, :show, :edit, :update, :destroy] do
    resources :jobs, only: [:new, :create, :show, :edit, :update, :destroy] do
      member do
        patch :toggle_enable
      end
    end

    resources :filesets, only: [:show, :new, :create, :destroy]
  end

  resources :schedules, only: [:show, :new, :edit, :create, :update, :destroy]

  root 'clients#index'
end
