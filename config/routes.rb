Rails.application.routes.draw do
  devise_for :admin_users
  root 'dashboard#index'

  resources :servers do
    resources :sites
  end
end
