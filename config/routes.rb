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
        match ':command', action: :command, as: :command, via: [:get, :patch]
      end
    end
    member do
      match 'config/:file', via: [:get, :post, :patch], action: :config_file, as: :config_file, constraints: ->(request) { Server::LOCATIONS.has_key? request.params[:file].downcase }
      match 'view-log', via: [:get, :patch]
      get 'output'
      get 'status'
      match ':command', action: :command, as: :command, via: [:get, :patch], constraints: ->(request) { Server::COMMANDS.include? request.params[:command].downcase }
    end
  end
end
