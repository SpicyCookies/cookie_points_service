# frozen_string_literal: true

# TODO: Scope all API endpoints to api/
Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'
  resources :users, only: [:create]

  # TODO: Scope /login to /users/login
  post '/login', to: 'users#login'
  resource :user, only: [:show, :update, :destroy]

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
