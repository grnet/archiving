Rails.application.routes.draw do
  root 'application#index'
  post 'grnet' => 'application#grnet'
  get 'institutional' => 'application#institutional'
  match 'vima', to: 'application#vima', :via => [:get, :post]
  get 'logout' => 'application#logout'

  resources :clients, only: [:index, :show] do
    member do
      get :jobs
      get :logs
      get :stats
      post :stats
      get :users
      get :restore
      post :run_restore
      post :restore_selected
    end

    collection do
      post :index
    end
  end

  resources :clients, only: [], param: :client_id do
    member do
      get :tree
    end
  end

  resources :hosts, only: [:new, :create, :show, :edit, :update, :destroy] do
    member do
      post :submit_config
      post :disable
      delete :revoke
    end

    resources :jobs, only: [:new, :create, :show, :edit, :update, :destroy] do
      member do
        patch :toggle_enable
        post :backup_now
      end
    end

    resources :filesets, only: [:show, :new, :create, :edit, :update, :destroy]
    resources :schedules, only: [:show, :new, :edit, :create, :update, :destroy]
  end

  namespace :admin do
    match '/', to: 'base#index', via: [:get, :post]

    get '/login' => 'base#login', as: :login

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
        post :disable
        post :block
        post :unblock
        delete :revoke
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

    resources :users, only: [:index, :new, :create, :show, :edit, :update] do
      member do
        patch :ban
        patch :unban
      end
    end

    resources :pools, only: [:index, :new, :create, :show, :edit, :update]
  end
end
