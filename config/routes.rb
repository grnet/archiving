Rails.application.routes.draw do
  resources :clients, only: [:index, :show]

  resources :hosts, only: [:new, :create, :show, :edit, :update, :destroy] do
    member do
      post :submit_config
      post :restore
      delete :revoke
    end

    resources :jobs, only: [:new, :create, :show, :edit, :update, :destroy] do
      member do
        patch :toggle_enable
        post :backup_now
      end
    end

    resources :filesets, only: [:show, :new, :create, :destroy]
    resources :schedules, only: [:show, :new, :edit, :create, :update, :destroy]
  end

  root 'clients#index'
end
