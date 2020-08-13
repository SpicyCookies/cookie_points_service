# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate!, only: [:show, :update, :destroy]

  #
  # /users
  # Registration action
  #

  def create
    @user = User.new(user_params)

    if @user.save
      user_json = UserBlueprint.render(
        @user,
        token: @user.generate_jwt,
        view: :created,
        root: :user
      )
      render json: user_json, status: :created
    else
      render json: { errors: @user.errors }, status: :bad_request
    end
  end

  #
  # /login
  # Login action
  #

  def login
    # user will be false/nil for invalid login params
    # user will contain User record for valid login params
    @user = User.authenticate(user_params[:email], user_params[:password]) ||
      User.authenticate(user_params[:username], user_params[:password])

    if @user
      render json: { user: { token: @user.generate_jwt } }.to_json, status: :ok
    else
      render json: { error: 'invalid email, username, or password' }.to_json, status: :unauthorized
    end
  end

  #
  # /user
  # User actions
  #

  def show
    user_json = UserBlueprint.render current_user, view: :normal, root: :user
    render json: user_json, status: :ok
  end

  def update
    if current_user.update(user_params)
      user_json = UserBlueprint.render current_user, view: :normal, root: :user
      render json: user_json, status: :ok
    else
      render json: { errors: current_user.errors }, status: :bad_request
    end
  end

  def destroy
    if current_user.destroy
      delete_message = {
        message: "Successfully deleted user #{current_user.username}"\
                 " with email #{current_user.email}"
      }
      render json: delete_message.to_json, status: :ok
    else
      render json: { error: 'Failed to delete account!' }, status: :bad_request
    end
  end

  # TODO: Add user memberships retrieval endpoint

  private

  def user_params
    params.require(:user).permit(:username, :email, :password)
  end
end
