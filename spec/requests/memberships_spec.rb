# frozen_string_literal: true

require 'rails_helper'

describe MembershipsController, type: :request do
  let(:headers) do
    {
      'Authorization' => "Token #{jwt_token}",
      'Content-Type' => 'application/json'
    }
  end

  let(:membership_user_id) { 2 }
  let(:membership_org_id) { 2 }
  before do
    FactoryBot.create(
      :user,
      id: membership_user_id
    )
    FactoryBot.create(
      :organization,
      id: membership_org_id
    )
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

    context 'with GET /memberships request' do
      let(:membership) do
        FactoryBot.create(
          :membership,
          user_id: membership_user_id,
          organization_id: membership_org_id
        )
      end

      subject do
        membership
        get '/memberships', headers: headers
      end

      it 'successfully retrieve an membership array' do
        subject
        expect(response).to have_http_status(200)
        response_body = JSON.parse(response.body)
        expect(response_body[0]['user_id']).to eq(membership_user_id)
        expect(response_body[0]['organization_id']).to eq(membership_org_id)
      end
    end

    context 'with POST /memberships request' do
      let(:membership_params) do
        {
          user_id: membership_user_id,
          organization_id: membership_org_id
        }
      end

      subject do
        post '/memberships', params: membership_params.to_json, headers: headers
      end

      it 'successfully creates a membership' do
        subject
        expect(response).to have_http_status(201)
        response_body = JSON.parse(response.body)
        expect(response_body['user_id']).to eq(membership_user_id)
        expect(response_body['organization_id']).to eq(membership_org_id)
      end

      it 'only creates one membership' do
        expect { subject }.to change { Membership.count }.by(1)
      end

      shared_examples 'an invalid blank attribute' do |attribute|
        let(:error_response) do
          {
            errors: {
              "#{attribute}": ['must exist']
            }
          }
        end

        it 'renders a bad request' do
          subject
          expect(response).to have_http_status(400)
          expect(response.body).to eq(error_response.to_json)
        end
      end

      context 'with an invalid blank membership user id' do
        let(:membership_params) do
          {
            user_id: nil,
            organization_id: membership_org_id
          }
        end

        it_behaves_like 'an invalid blank attribute', :user
      end

      context 'with an invalid blank membership organization id' do
        let(:membership_params) do
          {
            user_id: membership_user_id,
            organization_id: nil
          }
        end

        it_behaves_like 'an invalid blank attribute', :organization
      end
    end

    context 'with GET /memberships/{id} request' do
      let(:membership) do
        FactoryBot.create(
          :membership,
          user_id: membership_user_id,
          organization_id: membership_org_id
        )
      end
      let(:membership_id) { membership.id }

      subject do
        get "/memberships/#{membership_id}", headers: headers
      end

      it 'successfully retrieve a membership' do
        subject
        expect(response).to have_http_status(200)
        response_body = JSON.parse(response.body)
        expect(response_body['user_id']).to eq(membership_user_id)
        expect(response_body['organization_id']).to eq(membership_org_id)
      end

      context 'with an invalid lookup id' do
        let(:membership_id) { 12345 }

        let(:error_response) do
          {
            error: {
              class: 'Exceptions::MembershipError::MembershipNotFound',
              message: "ActiveRecord::RecordNotFound: Couldn't find membership with id: #{membership_id}"
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

    context 'with PUT /memberships/{id} request' do
      let(:membership) do
        FactoryBot.create(
          :membership,
          user_id: membership_user_id,
          organization_id: membership_org_id
        )
      end
      let(:membership_id) { membership.id }

      # Generate another valid user and organization
      let(:modified_user_id) { membership_user_id + 1 }
      let(:modified_org_id) { membership_org_id + 1 }
      let(:modified_membership_params) do
        {
          user_id: modified_user_id,
          organization_id: modified_org_id
        }
      end
      before do
        FactoryBot.create(
          :user,
          id: modified_user_id
        )
        FactoryBot.create(
          :organization,
          id: modified_org_id
        )
      end

      subject do
        put "/memberships/#{membership_id}", params: modified_membership_params.to_json, headers: headers
      end

      it 'successfully updates a membership' do
        subject
        expect(response).to have_http_status(200)
        response_body = JSON.parse(response.body)
        expect(response_body['user_id']).to eq(modified_user_id)
        expect(response_body['organization_id']).to eq(modified_org_id)
      end

      context 'with an invalid lookup id' do
        let(:membership_id) { 12345 }

        let(:error_response) do
          {
            error: {
              class: 'Exceptions::MembershipError::MembershipNotFound',
              message: "ActiveRecord::RecordNotFound: Couldn't find membership with id: #{membership_id}"
            }
          }
        end

        it 'renders a not found' do
          subject
          expect(response).to have_http_status(404)
          expect(response.body).to eq(error_response.to_json)
        end
      end

      shared_examples 'an invalid blank attribute' do |attribute|
        let(:error_response) do
          {
            errors: {
              "#{attribute}": ['must exist']
            }
          }
        end

        it 'renders a bad request' do
          subject
          expect(response).to have_http_status(400)
          expect(response.body).to eq(error_response.to_json)
        end
      end

      context 'with an invalid blank membership user id' do
        let(:modified_membership_params) do
          {
            user_id: nil,
            organization_id: membership_org_id
          }
        end

        it_behaves_like 'an invalid blank attribute', :user
      end

      context 'with an invalid blank membership organization id' do
        let(:modified_membership_params) do
          {
            user_id: membership_user_id,
            organization_id: nil
          }
        end

        it_behaves_like 'an invalid blank attribute', :organization
      end
    end

    context 'with DELETE /memberships/{id} request' do
      let(:membership) do
        FactoryBot.create(
          :membership,
          user_id: membership_user_id,
          organization_id: membership_org_id
        )
      end
      let(:membership_id) { membership.id }

      subject do
        delete "/memberships/#{membership_id}", headers: headers
      end

      let(:response_message) do
        {
          message: "Successfully deleted membership with user_id: #{membership_user_id}, organization_id: #{membership_org_id}"
        }
      end

      context 'with a failed destroy' do
        let(:mock_membership) { double(Membership, destroy: false) }
        before do
          allow(Membership)
            .to receive(:find)
            .with(membership_id.to_s)
            .and_return(mock_membership)
        end

        let(:error_response) do
          {
            error: 'Failed to delete membership!'
          }
        end

        it 'renders an bad request' do
          subject
          expect(response).to have_http_status(400)
          expect(response.body).to eq(error_response.to_json)
        end
      end

      it 'successfully deletes a membership' do
        subject
        expect(response).to have_http_status(200)
        expect(response.body).to eq(response_message.to_json)
      end

      context 'with an invalid lookup id' do
        let(:membership_id) { 12345 }

        let(:error_response) do
          {
            error: {
              class: 'Exceptions::MembershipError::MembershipNotFound',
              message: "ActiveRecord::RecordNotFound: Couldn't find membership with id: #{membership_id}"
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

    context 'with GET /memberships request' do
      subject { get '/memberships', headers: headers }

      it 'renders an unauthorized error' do
        subject
        expect(response).to have_http_status(401)
        expect(response.body).to eq(error_response.to_json)
      end
    end

    context 'with POST /memberships request' do
      let(:membership_params) do
        {
          user_id: 1,
          organization_id: 1,
        }
      end

      subject { post '/memberships', params: membership_params.to_json, headers: headers }

      it 'renders an unauthorized error' do
        subject
        expect(response).to have_http_status(401)
        expect(response.body).to eq(error_response.to_json)
      end
    end

    context 'with GET /memberships/{id} request' do
      subject { get '/memberships/1', headers: headers }

      it 'renders an unauthorized error' do
        subject
        expect(response).to have_http_status(401)
        expect(response.body).to eq(error_response.to_json)
      end
    end

    context 'with PUT /memberships/{id} request' do
      let(:modified_membership_params) do
        {
          user_id: 1,
          organization_id: 1
        }
      end

      subject do
        put '/memberships/1', params: modified_membership_params.to_json, headers: headers
      end

      it 'renders an unauthorized error' do
        subject
        expect(response).to have_http_status(401)
        expect(response.body).to eq(error_response.to_json)
      end
    end

    context 'with DELETE /memberships/{id} request' do
      subject { delete '/memberships/1', headers: headers }

      it 'renders an unauthorized error' do
        subject
        expect(response).to have_http_status(401)
        expect(response.body).to eq(error_response.to_json)
      end
    end
  end
end
