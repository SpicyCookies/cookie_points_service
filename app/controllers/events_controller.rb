# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authenticate!

  # GET /organization/{organization_id}/events
  # Endpoint functionality used by Organizations
  def index
    organization = Organization.find(params[:organization_id])
    events = organization.events

    render json: events.to_json, status: :ok
  end

  # POST /organization/{organization_id}/events
  def create
    create_event_params = event_params.merge(organization_id: params[:organization_id])
    event = Event.new(create_event_params)

    if event.save
      render json: event.to_json, status: :created
    else
      render json: { errors: event.errors }, status: :bad_request
    end
  end

  # GET /organization/{organization_id}/events/{id}
  def show
    organization = Organization.find(params[:organization_id])
    event = organization.events.find(params[:id])

    render json: event.to_json, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    error_msg = "Couldn't find event with id: #{params['id']}"
    raise Exceptions::EventError::EventNotFound, "#{e.class}: #{error_msg}"
  end

  # PUT /organization/{organization_id}/events/{id}
  def update
    organization = Organization.find(params[:organization_id])
    event = organization.events.find(params[:id])

    if event.update(event_params)
      render json: event.to_json, status: :ok
    else
      render json: { errors: event.errors }, status: :bad_request
    end
  rescue ActiveRecord::RecordNotFound => e
    error_msg = "Couldn't find event with id: #{params['id']}"
    raise Exceptions::EventError::EventNotFound, "#{e.class}: #{error_msg}"
  end

  # DELETE /organization/{organization_id}/events/{id}
  def destroy
    organization = Organization.find(params[:organization_id])
    event = organization.events.find(params[:id])

    if event.destroy
      delete_message = {
        message: "Successfully deleted event_id: #{params[:id]} for "\
                 "organization_id: #{event.organization_id}"
      }
      render json: delete_message.to_json, status: :ok
    else
      render json: { error: 'Failed to delete event!' }, status: :bad_request
    end
  rescue ActiveRecord::RecordNotFound => e
    error_msg = "Couldn't find event with id: #{params['id']}"
    raise Exceptions::EventError::EventNotFound, "#{e.class}: #{error_msg}"
  end

  private

  def event_params
    params.require(:event).permit(:organization_id, :name, :description, :start_time, :end_time)
  end
end
