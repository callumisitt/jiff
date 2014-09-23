Rails.application.routes.draw do
  devise_for :admin_users
  root 'dashboard#index'

  resources :server do
    resources :site do
      member do
        match 'view-log', via: [:get, :patch]
        match 'toggle', via: [:get, :patch]
        match 'virtual-host-config', via: [:get, :patch]
        match 'rake-task', via: [:get, :patch]
      end
    end
    member do
      match 'config/:file', via: [:get, :post, :patch], action: :config_file, as: :config_file, constraints: ->(request) { Server::LOCATIONS.has_key? request.params[:file].downcase }
      match 'view-log', via: [:get, :patch]
      get 'output'
      get 'status'
    end
  end
  
  get "/server/:id/view-type/:view_type" => 'server#show'
  get "/server/:id/:command" => 'server#command', as: 'command_server'
  get "/server/:server_id/site/:id/:command" => 'site#command', as: 'command_site'
end
