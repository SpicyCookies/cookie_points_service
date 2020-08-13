# frozen_string_literal: true

class MembershipsController < ApplicationController
  def index
    # TODO: Add query params
    membership = Membership.all
    render json: membership.to_json, status: :ok
  end

  def create
    membership = Membership.new(membership_params)

    if membership.save
      render json: membership.to_json, status: :created
    else
      render json: { errors: membership.errors }, status: :bad_request
    end
  end

  def show
    membership = Membership.find params[:id]
    render json: membership.to_json, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    error_msg = "Couldn't find membership with id: #{params['id']}"
    raise Exceptions::MembershipError::MembershipNotFound, "#{e.class}: #{error_msg}"
  end

  def update
    membership = Membership.find(params[:id])

    if membership.update(membership_params)
      render json: membership.to_json, status: :ok
    else
      render json: { errors: membership.errors }, status: :bad_request
    end
  rescue ActiveRecord::RecordNotFound => e
    error_msg = "Couldn't find membership with id: #{params['id']}"
    raise Exceptions::MembershipError::MembershipNotFound, "#{e.class}: #{error_msg}"
  end

  def destroy
    membership = Membership.find(params[:id])

    if membership.destroy
      delete_message = {
        message: 'Successfully deleted membership with '\
                 "user_id: #{membership.user_id}, organization_id: #{membership.organization_id}"
      }
      render json: delete_message.to_json, status: :ok
    else
      render json: { error: 'Failed to delete membership!' }, status: :bad_request
    end
  rescue ActiveRecord::RecordNotFound => e
    error_msg = "Couldn't find membership with id: #{params['id']}"
    raise Exceptions::MembershipError::MembershipNotFound, "#{e.class}: #{error_msg}"
  end

  private

  def membership_params
    params.require(:membership).permit(:user_id, :organization_id)
  end
end
