# frozen_string_literal: true

# TODO: Scope all API endpoints to api/
Rails.application.routes.draw do
  #
  # User endpoints
  #
  # TODO: Scope /login to /users/login

  # Registration
  resources :users, only: [:create], format: 'json'

  # Login
  post '/login', to: 'users#login', format: 'json'

  # Current user actions
  resource :user, only: [:show, :update, :destroy], format: 'json' do
    get 'memberships', to: 'users#memberships', format: 'json'
  end

  #
  # Organization endpoints
  #

  # Organization CRUD
  resources :organizations, only: [:index, :create, :show, :update, :destroy], format: 'json'
  get 'organizations/:id/memberships', to: 'organizations#memberships', format: 'json'

  #
  # Membership endpoints
  #

  # Membership CRUD
  resources :memberships, only: [:index, :create, :show, :update, :destroy], format: 'json'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
