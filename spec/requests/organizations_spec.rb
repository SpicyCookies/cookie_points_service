# frozen_string_literal: true

require 'rails_helper'

describe OrganizationsController, type: :request do
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

    let(:organization_name) { 'test_organization' }
    let(:organization_total_members) { 0 }
    let(:organization_description) { 'Test description.' }

    context 'with GET /organizations request' do
      before do
        FactoryBot.create(
          :organization,
          name: organization_name,
          total_members: organization_total_members,
          description: organization_description
        )
      end

      subject do
        get '/organizations', headers: headers
      end

      it 'successfully retrieve an organization array' do
        subject
        expect(response).to have_http_status(200)
        response_body = JSON.parse(response.body)
        expect(response_body[0]['name']).to eq(organization_name)
        expect(response_body[0]['total_members']).to eq(organization_total_members)
        expect(response_body[0]['description']).to eq(organization_description)
      end

      context 'with name in query params' do
        before do
          FactoryBot.create(
            :organization,
            name: "#{organization_name}not_query",
            total_members: organization_total_members,
            description: organization_description
          )
        end

        subject do
          get '/organizations', params: { name: organization_name }, headers: headers
        end

        it 'successfully retrieves the queried organization' do
          subject
          expect(response).to have_http_status(200)
          response_body = JSON.parse(response.body)
          expect(response_body[0]['name']).to eq(organization_name)
          expect(response_body[0]['total_members']).to eq(organization_total_members)
          expect(response_body[0]['description']).to eq(organization_description)
          expect(response_body.size).to eq(1)
        end
      end
    end

    context 'with POST /organizations request' do
      let(:organization_params) do
        {
          name: organization_name,
          total_members: organization_total_members,
          description: organization_description
        }
      end

      subject do
        post '/organizations', params: organization_params.to_json, headers: headers
      end

      it 'successfully creates an organization' do
        subject
        expect(response).to have_http_status(201)
        response_body = JSON.parse(response.body)
        expect(response_body['name']).to eq(organization_name)
        expect(response_body['total_members']).to eq(organization_total_members)
        expect(response_body['description']).to eq(organization_description)
      end

      it 'only creates one organization' do
        expect { subject }.to change { Organization.count }.by(1)
      end

      context 'with invalid duplicate name' do
        let(:error_response) do
          {
            errors: {
              name: ['has already been taken']
            }
          }
        end

        before do
          FactoryBot.create(
            :organization,
            name: organization_name,
            total_members: organization_total_members,
            description: organization_description
          )
        end

        it 'renders a bad request' do
          subject
          expect(response).to have_http_status(400)
          expect(response.body).to eq(error_response.to_json)
        end
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

      context 'with an invalid blank name' do
        let(:organization_params) do
          {
            name: nil,
            total_members: organization_total_members,
            description: organization_description
          }
        end

        it_behaves_like 'an invalid blank attribute', :name
      end

      context 'with an invalid blank total_members' do
        let(:organization_params) do
          {
            name: organization_name,
            total_members: nil,
            description: organization_description
          }
        end

        it_behaves_like 'an invalid blank attribute', :total_members
      end

      context 'with an invalid blank description' do
        let(:organization_params) do
          {
            name: organization_name,
            total_members: organization_total_members,
            description: nil
          }
        end

        it_behaves_like 'an invalid blank attribute', :description
      end
    end

    context 'with GET /organizations/{id} request' do
      let(:organization) do
        FactoryBot.create(
          :organization,
          name: organization_name,
          total_members: organization_total_members,
          description: organization_description
        )
      end
      let(:organization_id) { organization.id }

      subject do
        get "/organizations/#{organization_id}", headers: headers
      end

      it 'successfully retrieve an organization' do
        subject
        expect(response).to have_http_status(200)
        response_body = JSON.parse(response.body)
        expect(response_body['name']).to eq(organization_name)
        expect(response_body['total_members']).to eq(organization_total_members)
        expect(response_body['description']).to eq(organization_description)
      end

      context 'with an invalid lookup id' do
        let(:organization_id) { 12345 }

        let(:error_response) do
          {
            error: {
              class: 'Exceptions::OrganizationError::OrganizationNotFound',
              message: "ActiveRecord::RecordNotFound: Couldn't find organization with id: #{organization_id}"
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

    context 'with PUT /organizations/{id} request' do
      let(:organization) do
        FactoryBot.create(
          :organization,
          name: organization_name,
          total_members: organization_total_members,
          description: organization_description
        )
      end
      let(:organization_id) { organization.id }

      let(:modified_name) { "mod#{organization_name}" }
      let(:modified_total_members) { organization_total_members + 1 }
      let(:modified_description) { "mod#{organization_description}" }
      let(:modified_organization_params) do
        {
          name: modified_name,
          total_members: modified_total_members,
          description: modified_description
        }
      end

      subject do
        put "/organizations/#{organization_id}", params: modified_organization_params.to_json, headers: headers
      end

      it 'successfully updates an organization' do
        subject
        expect(response).to have_http_status(200)
        response_body = JSON.parse(response.body)
        expect(response_body['name']).to eq(modified_name)
        expect(response_body['total_members']).to eq(modified_total_members)
        expect(response_body['description']).to eq(modified_description)
      end

      context 'with invalid duplicate name' do
        let(:error_response) do
          {
            errors: {
              name: ['has already been taken']
            }
          }
        end

        before do
          FactoryBot.create(
            :organization,
            name: modified_name,
            total_members: organization_total_members,
            description: organization_description
          )
        end

        it 'renders a bad request' do
          subject
          expect(response).to have_http_status(400)
          expect(response.body).to eq(error_response.to_json)
        end
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

      context 'with an invalid blank name' do
        let(:modified_name) { nil }

        it_behaves_like 'an invalid blank attribute', :name
      end

      context 'with an invalid blank total_members' do
        let(:modified_total_members) { nil }

        it_behaves_like 'an invalid blank attribute', :total_members
      end

      context 'with an invalid blank description' do
        let(:modified_description) { nil }

        it_behaves_like 'an invalid blank attribute', :description
      end

      context 'with an invalid lookup id' do
        let(:organization_id) { 12345 }

        let(:error_response) do
          {
            error: {
              class: 'Exceptions::OrganizationError::OrganizationNotFound',
              message: "ActiveRecord::RecordNotFound: Couldn't find organization with id: #{organization_id}"
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

    context 'with DELETE /organizations/{id} request' do
      let(:organization) do
        FactoryBot.create(
          :organization,
          name: organization_name,
          total_members: organization_total_members,
          description: organization_description
        )
      end
      let(:organization_id) { organization.id }

      subject do
        delete "/organizations/#{organization_id}", headers: headers
      end

      let(:response_message) do
        {
          message: 'Successfully deleted organization test_organization'
        }
      end

      it 'successfully deletes an organization' do
        subject
        expect(response).to have_http_status(200)
        expect(response.body).to eq(response_message.to_json)
      end

      context 'with a failed destroy' do
        let(:mock_organization) { double(Organization, destroy: false) }
        before do
          allow(Organization)
            .to receive(:find)
            .with(organization_id.to_s)
            .and_return(mock_organization)
        end

        let(:error_response) do
          {
            error: 'Failed to delete organization!'
          }
        end

        it 'renders an bad request' do
          subject
          expect(response).to have_http_status(400)
          expect(response.body).to eq(error_response.to_json)
        end
      end

      context 'with an invalid lookup id' do
        let(:organization_id) { 12345 }

        let(:error_response) do
          {
            error: {
              class: 'Exceptions::OrganizationError::OrganizationNotFound',
              message: "ActiveRecord::RecordNotFound: Couldn't find organization with id: #{organization_id}"
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

    context 'with GET /organizations request' do
      subject { get '/organizations', headers: headers }

      it 'renders an unauthorized error' do
        subject
        expect(response).to have_http_status(401)
        expect(response.body).to eq(error_response.to_json)
      end
    end

    context 'with POST /organizations request' do
      let(:organization_params) do
        {
          name: 'organization_name',
          total_members: 0,
          description: 'organization_description'
        }
      end

      subject { post '/organizations', params: organization_params.to_json, headers: headers }

      it 'renders an unauthorized error' do
        subject
        expect(response).to have_http_status(401)
        expect(response.body).to eq(error_response.to_json)
      end
    end

    context 'with GET /organizations/{id} request' do
      subject { get '/organizations/1', headers: headers }

      it 'renders an unauthorized error' do
        subject
        expect(response).to have_http_status(401)
        expect(response.body).to eq(error_response.to_json)
      end
    end

    context 'with PUT /organizations/{id} request' do
      let(:modified_organization_params) do
        {
          name: 'modified_name',
          total_members: 1,
          description: 'modified_description'
        }
      end

      subject do
        put '/organizations/1', params: modified_organization_params.to_json, headers: headers
      end

      it 'renders an unauthorized error' do
        subject
        expect(response).to have_http_status(401)
        expect(response.body).to eq(error_response.to_json)
      end
    end

    context 'with DELETE /organizations/{id} request' do
      subject { delete '/organizations/1', headers: headers }

      it 'renders an unauthorized error' do
        subject
        expect(response).to have_http_status(401)
        expect(response.body).to eq(error_response.to_json)
      end
    end
  end
end
