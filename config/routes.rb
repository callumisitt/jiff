Rails.application.routes.draw do
  devise_for :admin_users
  root 'dashboard#index'

  resources :server do
    resources :site
    member do
      match 'apache-config', via: [:get, :patch]
    end
  end
  
  get "/server/:id/:command" => "server#command", as: "server_command"
end
