Rails.application.routes.draw do
  devise_for :admin_users
  root 'dashboard#index'

  resources :server do
    resources :site do
      member do
        get 'view-log'
        match 'toggle', via: [:get, :patch]        
        match 'virtual-host-config', via: [:get, :patch]
      end
    end
    member do
      match 'apache-config', via: [:get, :patch]
    end
  end
  
  get "/server/:id/:command" => "server#command", as: "server_command"
end
