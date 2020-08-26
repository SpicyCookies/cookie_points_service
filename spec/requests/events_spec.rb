# frozen_string_literal: true

require 'rails_helper'

# /organizations/{id}/events
describe EventsController, type: :request do
  let(:headers) do
    {
      'Authorization' => "Token #{jwt_token}",
      'Content-Type' => 'application/json'
    }
  end

  describe 'authenticated requests' do
    let(:user_id) { 1 }
    let(:user_username) { 'testusername' }
    let(:user_email) { 'test@gmail.com' }
    let(:user_password) { 'test-password' }
    let(:created_at) { DateTime.now }
    let(:user) do
      FactoryBot.create(
        :user,
        id: user_id,
        username: user_username,
        email: user_email,
        password: user_password,
        created_at: created_at
      )
    end
    let(:jwt_token) { user.generate_jwt }

    let(:organization) do
      FactoryBot.create(
        :organization
      )
    end
    let(:organization_id) { organization.id }

    context 'with GET /organizations/:organization_id/events request' do
      let(:event) do
        FactoryBot.create(
          :event,
          organization_id: organization_id
        )
      end
      let(:event_id) { event.id }
      let(:event_organization_id) { event.organization_id }
      let(:event_name) { event.name }
      let(:event_description) { event.description }
      let(:event_start_time) { event.start_time }
      let(:event_end_time) { event.end_time }

      subject do
        event
        get "/organizations/#{organization_id}/events", headers: headers
      end

      it 'successfully retrieve a event array' do
        subject
        expect(response).to have_http_status(200)
        response_body = JSON.parse(response.body)
        expect(response_body[0]['id']).to eq(event_id)
        expect(response_body[0]['organization_id']).to eq(event_organization_id)
        expect(response_body[0]['name']).to eq(event_name)
        expect(response_body[0]['description']).to eq(event_description)
        expect(response_body[0]['start_time']).to eq(event_start_time.utc.iso8601(3))
        expect(response_body[0]['end_time']).to eq(event_end_time.utc.iso8601(3))
      end
    end

    context 'with POST /organizations/:organization_id/events request' do
      let(:name) { 'test name' }
      let(:description) { 'Test description.' }
      let(:start_time) { '2020-08-18T02:32:55.501Z' }
      let(:end_time) { '2020-08-18T02:32:55.501Z' }
      let(:event_params) do
        {
          name: name,
          description: description,
          start_time: start_time,
          end_time: end_time
        }
      end

      subject do
        post "/organizations/#{organization_id}/events", params: event_params.to_json, headers: headers
      end

      it 'successfully creates an event' do
        subject
        expect(response).to have_http_status(201)
        response_body = JSON.parse(response.body)
        expect(response_body['organization_id']).to eq(organization_id)
        expect(response_body['name']).to eq(name)
        expect(response_body['description']).to eq(description)
        expect(response_body['start_time']).to eq(Time.parse(start_time).utc.iso8601(3))
        expect(response_body['end_time']).to eq(Time.parse(end_time).utc.iso8601(3))
      end

      it 'only creates one event' do
        expect { subject }.to change { Event.count }.by(1)
      end

      shared_examples 'an invalid blank attribute' do |attribute|
        let(:error_response) do
          {
            errors: {
              "#{attribute}": ['can\'t be blank']
            }
          }
        end

        it 'renders a bad request' do
          subject
          expect(response).to have_http_status(400)
          expect(response.body).to eq(error_response.to_json)
        end
      end

      context 'with a blank name' do
        let(:event_params) do
          {
            name: nil,
            description: 'Test description.',
            startTime: '2020-08-18T02:32:55.501Z',
            endTime: '2020-08-18T02:32:55.501Z'
          }
        end

        it_behaves_like 'an invalid blank attribute', :name
      end

      context 'with a blank description' do
        let(:event_params) do
          {
            name: 'test_name',
            description: nil,
            startTime: '2020-08-18T02:32:55.501Z',
            endTime: '2020-08-18T02:32:55.501Z'
          }
        end

        it_behaves_like 'an invalid blank attribute', :description
      end

      context 'with a blank start time' do
        let(:event_params) do
          {
            name: 'test_name',
            description: 'Test description.',
            startTime: nil,
            endTime: '2020-08-18T02:32:55.501Z'
          }
        end

        it_behaves_like 'an invalid blank attribute', :start_time
      end

      context 'with a blank end time' do
        let(:event_params) do
          {
            name: 'test_name',
            description: 'Test description.',
            startTime: '2020-08-18T02:32:55.501Z',
            endTime: nil
          }
        end

        it_behaves_like 'an invalid blank attribute', :end_time
      end
    end

    context 'with GET /organizations/:organization_id/events/:id request' do
      let(:event_id) { 123 }
      let(:event_id_param) { event_id }
      let(:event) do
        FactoryBot.create(
          :event,
          id: event_id,
          organization_id: organization_id
        )
      end
      let(:event_organization_id) { event.organization_id }
      let(:event_name) { event.name }
      let(:event_description) { event.description }
      let(:event_start_time) { event.start_time }
      let(:event_end_time) { event.end_time }
      before do
        event
      end

      subject do
        get "/organizations/#{organization_id}/events/#{event_id_param}", headers: headers
      end

      it 'successfully retrieve an event' do
        subject
        expect(response).to have_http_status(200)
        response_body = JSON.parse(response.body)
        expect(response_body['id']).to eq(event_id)
        expect(response_body['organization_id']).to eq(event_organization_id)
        expect(response_body['name']).to eq(event_name)
        expect(response_body['description']).to eq(event_description)
        expect(response_body['start_time']).to eq(event_start_time.utc.iso8601(3))
        expect(response_body['end_time']).to eq(event_end_time.utc.iso8601(3))
      end

      context 'with an invalid lookup id' do
        let(:event_id_param) { event_id + 1 }

        let(:error_response) do
          {
            error: {
              class: 'Exceptions::EventError::EventNotFound',
              message: "ActiveRecord::RecordNotFound: Couldn't find event with id: #{event_id_param}"
            }
          }
        end

        it 'renders a not found' do
          subject
          expect(response).to have_http_status(404)
          expect(response.body).to eq(error_response.to_json)
        end
      end
    end

    context 'with PUT /organizations/:organization_id/events/:id request' do
      let(:event_id) { 123 }
      let(:event_id_param) { event_id }
      let(:event) do
        FactoryBot.create(
          :event,
          id: event_id,
          organization_id: organization_id
        )
      end
      let(:event_organization_id) { event.organization_id }
      let(:event_name) { event.name }
      let(:event_description) { event.description }
      let(:event_start_time) { event.start_time }
      let(:event_end_time) { event.end_time }

      let(:modified_event_name) { "mod#{event_name}" }
      let(:modified_event_description) { "mod#{event_description}" }
      let(:modified_event_start_time) { event_start_time }
      let(:modified_event_end_time) { event_end_time }
      let(:modified_event_params) do
        {
          name: modified_event_name,
          description: modified_event_description,
          start_time: modified_event_start_time,
          end_time: modified_event_end_time
        }
      end

      before do
        event
      end

      subject do
        put "/organizations/#{organization_id}/events/#{event_id_param}", params: modified_event_params.to_json, headers: headers
      end

      it 'successfully updates an event' do
        subject
        expect(response).to have_http_status(200)
        response_body = JSON.parse(response.body)
        expect(response_body['id']).to eq(event_id)
        expect(response_body['organization_id']).to eq(event_organization_id)
        expect(response_body['name']).to eq(modified_event_name)
        expect(response_body['description']).to eq(modified_event_description)
        expect(response_body['start_time']).to eq(modified_event_start_time.utc.iso8601(3))
        expect(response_body['end_time']).to eq(modified_event_end_time.utc.iso8601(3))
      end

      context 'with an invalid lookup id' do
        let(:event_id_param) { event_id + 1 }

        let(:error_response) do
          {
            error: {
              class: 'Exceptions::EventError::EventNotFound',
              message: "ActiveRecord::RecordNotFound: Couldn't find event with id: #{event_id_param}"
            }
          }
        end

        it 'renders a not found' do
          subject
          expect(response).to have_http_status(404)
          expect(response.body).to eq(error_response.to_json)
        end
      end
    end

    context 'with DELETE /organizations/:organization_id/events/:id request' do
      let(:event_id) { 123 }
      let(:event_id_param) { event_id }
      let(:event) do
        FactoryBot.create(
          :event,
          id: event_id,
          organization_id: organization_id
        )
      end
      before do
        event
      end

      subject do
        delete "/organizations/#{organization_id}/events/#{event_id_param}", headers: headers
      end

      let(:response_message) do
        {
          message: "Successfully deleted event_id: #{event_id_param} for organization_id: #{organization_id}"
        }
      end

      it 'successfully deletes an event' do
        subject
        expect(response).to have_http_status(200)
        expect(response.body).to eq(response_message.to_json)
      end

      context 'with a failed destroy' do
        let(:mock_event) { double(Event, destroy: false) }
        let(:mock_events) { double('EventList', find: mock_event) }
        let(:mock_organization) { double(Organization, events: mock_events) }
        before do
          allow(Organization)
            .to receive(:find)
            .with(organization_id.to_s)
            .and_return(mock_organization)
        end

        let(:error_response) do
          {
            error: 'Failed to delete event!'
          }
        end

        it 'renders a bad request' do
          subject
          expect(response).to have_http_status(400)
          expect(response.body).to eq(error_response.to_json)
        end
      end

      context 'with an invalid lookup id' do
        let(:event_id_param) { event_id + 1 }

        let(:error_response) do
          {
            error: {
              class: 'Exceptions::EventError::EventNotFound',
              message: "ActiveRecord::RecordNotFound: Couldn't find event with id: #{event_id_param}"
            }
          }
        end

        it 'renders a not found' do
          subject
          expect(response).to have_http_status(404)
          expect(response.body).to eq(error_response.to_json)
        end
      end
    end
  end

  describe 'unauthenticated requests' do
    let(:jwt_token) { 'invalid' }

    let(:error_response) do
      {
        error: {
          class: 'Exceptions::AuthenticationError::InvalidToken',
          message: 'JWT::DecodeError: Not enough or too many segments'
        }
      }
    end

    context 'with GET /organizations/:organization_id/events request' do
      subject { get '/organizations/1/events', headers: headers }

      it 'renders an unauthorized error' do
        subject
        expect(response).to have_http_status(401)
        expect(response.body).to eq(error_response.to_json)
      end
    end

    context 'with POST /organizations/:organization_id/events request' do
      let(:membership_params) { {} }

      subject { post '/organizations/1/events', params: membership_params.to_json, headers: headers }

      it 'renders an unauthorized error' do
        subject
        expect(response).to have_http_status(401)
        expect(response.body).to eq(error_response.to_json)
      end
    end

    context 'with GET /organizations/:organization_id/events/:id request' do
      subject { get '/organizations/1/events/1', headers: headers }

      it 'renders an unauthorized error' do
        subject
        expect(response).to have_http_status(401)
        expect(response.body).to eq(error_response.to_json)
      end
    end

    context 'with PUT /organizations/:organization_id/events/:id request' do
      let(:modified_membership_params) { {} }

      subject do
        put '/organizations/1/events/1', params: modified_membership_params.to_json, headers: headers
      end

      it 'renders an unauthorized error' do
        subject
        expect(response).to have_http_status(401)
        expect(response.body).to eq(error_response.to_json)
      end
    end

    context 'with DELETE /organizations/:organization_id/events/:id request' do
      subject { delete '/organizations/1/events/1', headers: headers }

      it 'renders an unauthorized error' do
        subject
        expect(response).to have_http_status(401)
        expect(response.body).to eq(error_response.to_json)
      end
    end
  end
end
