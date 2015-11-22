Rails.application.routes.draw do
  root 'clients#index'

  resources :clients, only: [:index, :show] do
    member do
      get :jobs
      get :logs
      get :stats
    end
  end

  resources :hosts, only: [:new, :create, :show, :edit, :update, :destroy] do
    member do
      post :submit_config
      get :restore
      post :run_restore
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

  namespace :admin do
    get '/' => 'base#index'

    resources :clients, only: [:index, :show] do
      member do
        get :jobs
        get :logs
        get :stats
        post :stats
      end
    end
  end
end
