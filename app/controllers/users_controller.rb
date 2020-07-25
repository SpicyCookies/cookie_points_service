# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate!, only: [:show, :update, :destroy]

  #
  # /users
  # Registration action
  #

  def create
    @user = User.new(user_params)
    @user.save!

    user_json = UserBlueprint.render(
      @user,
      token: @user.generate_jwt,
      view: :created,
      root: :user
    )
    render json: user_json
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
      render json: { user: { token: @user.generate_jwt } }.to_json
    else
      render json: { message: 'invalid username or password' }.to_json
    end
  end

  #
  # /user
  # User actions
  #

  def show
    user_json = UserBlueprint.render current_user, view: :normal, root: :user
    render json: user_json
  end

  def update
    if current_user.update(user_params)
      render :show
    else
      render json: { errors: current_user.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.destroy
      delete_message = {
        message: "Successfully deleted user #{current_user.username}"\
                 " with email #{current_user.email}"
      }
      render json: delete_message.to_json
    else
      render json: { errors: 'Failed to delete account!' }, status: :bad_request
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password)
  end
end
