# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :authenticate!

  def index
    # TODO: Add query params
    organization = Organization.all
    render json: organization.to_json, status: :ok
  end

  def create
    organization = Organization.new(organization_params)

    if organization.save
      render json: organization.to_json, status: :created
    else
      render json: { errors: organization.errors }, status: :bad_request
    end
  end

  def show
    organization = Organization.find params[:id]
    render json: organization.to_json, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    error_msg = "Couldn't find organization with id: #{params['id']}"
    raise Exceptions::OrganizationError::OrganizationNotFound, "#{e.class}: #{error_msg}"
  end

  def update
    organization = Organization.find(params[:id])

    if organization.update(organization_params)
      render json: organization.to_json, status: :ok
    else
      render json: { errors: organization.errors }, status: :bad_request
    end
  rescue ActiveRecord::RecordNotFound => e
    error_msg = "Couldn't find organization with id: #{params['id']}"
    raise Exceptions::OrganizationError::OrganizationNotFound, "#{e.class}: #{error_msg}"
  end

  def destroy
    organization = Organization.find(params[:id])

    if organization.destroy
      delete_message = {
        message: "Successfully deleted organization #{organization.name}"
      }
      render json: delete_message.to_json, status: :ok
    else
      render json: { error: 'Failed to delete organization!' }, status: :bad_request
    end
  rescue ActiveRecord::RecordNotFound => e
    error_msg = "Couldn't find organization with id: #{params['id']}"
    raise Exceptions::OrganizationError::OrganizationNotFound, "#{e.class}: #{error_msg}"
  end

  # TODO: Add user memberships retrieval endpoint or add memberships to CRUD responses

  private

  def organization_params
    params.require(:organization).permit(:name, :total_members, :description)
  end
end
