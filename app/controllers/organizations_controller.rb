# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :authenticate!

  # GET /organizations
  def index
    # Permitted query params
    permitted_name_param = params.permit(:name)

    organization = if permitted_name_param[:name].present?
                     # Return [result] or [] when passed a name in the query params
                     Array Organization.find_by(name: permitted_name_param[:name]) || []
                   else
                     # Return all organizations when not passed query params
                     Organization.all
                   end

    render json: organization.to_json, status: :ok
  end

  # POST /organizations
  def create
    organization = Organization.new(organization_params)

    if organization.save
      render json: organization.to_json, status: :created
    else
      render json: { errors: organization.errors }, status: :bad_request
    end
  end

  # GET /organizations/{id}
  def show
    organization = Organization.find params[:id]
    render json: organization.to_json, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    error_msg = "Couldn't find organization with id: #{params['id']}"
    raise Exceptions::OrganizationError::OrganizationNotFound, "#{e.class}: #{error_msg}"
  end

  # PUT /organizations/{id}
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

  # DELETE /organizations/{id}
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

  # GET /organizations/{id}/memberships
  def memberships
    organization = Organization.find(params[:id])
    memberships = organization.memberships
    render json: memberships.to_json, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    error_msg = "Couldn't find organization with id: #{params['id']}"
    raise Exceptions::OrganizationError::OrganizationNotFound, "#{e.class}: #{error_msg}"
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :total_members, :description)
  end
end
