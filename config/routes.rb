Rails.application.routes.draw do
  root 'application#index'
  post 'login' => 'application#login'
  match 'vima', to: 'application#vima', :via => [:get, :post]
  get 'logout' => 'application#logout'

  resources :clients, only: [:index, :show] do
    member do
      get :jobs
      get :logs
      get :stats
      post :stats
      get :users
    end

    collection do
      post :index
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
    match '/', to: 'base#index', via: [:get, :post]

    resources :settings, only: [:index, :new, :create, :edit, :update] do
      member do
        delete :reset
      end
    end

    resources :clients, only: [:index, :show] do
      member do
        get :jobs
        get :logs
        get :stats
        post :stats
        get :configuration
      end
    end

    resources :hosts, only: [:show] do
      collection do
        get :unverified
      end

      member do
        post :verify
      end
    end
  end
end
