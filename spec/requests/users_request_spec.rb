# frozen_string_literal: true

require 'rails_helper'

describe UsersController, type: :request do
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

    shared_examples 'a token with an invalid user_id payload' do
      let(:jwt_token) { 'invalidjwttoken' }
      let(:jwt_user_id) { 123 }
      let(:jwt_payload) do
        {
          id: jwt_user_id
        }.stringify_keys
      end

      context 'with current_user not found' do
        let(:expected_error_message) do
          {
            'error': {
              'class': 'Exceptions::AuthenticationError::UserNotFound',
              'message': "ActiveRecord::RecordNotFound: Couldn't find user with id: #{jwt_user_id}"
            }
          }.to_json
        end
        before do
          allow(JWT)
            .to receive(:decode)
            .with(jwt_token, Rails.application.secrets.secret_key_base)
            .and_return([jwt_payload])
        end

        it 'renders unauthorized error status' do
          subject
          expect(response.status).to eq(401)
        end

        it 'renders error message' do
          subject
          expect(response.body).to eq(expected_error_message)
        end
      end
    end

    context 'with GET /user request' do
      let(:expected_response_body) do
        {
          'user': {
            'id': user_id,
            'createdAt': created_at.utc.to_s,
            'email': user_email,
            'username': user_username
          }
        }.to_json
      end

      subject do
        get '/user', params: {}, headers: headers
      end

      it 'allows show action' do
        subject
        expect(response.status).to eq(200)
      end

      it 'displays user information' do
        subject
        expect(response.body).to eq(expected_response_body)
      end

      it_behaves_like 'a token with an invalid user_id payload'
    end

    context 'with PUT /user request' do
      let(:modified_user_email) { 'modifiedtest@gmail.com' }
      let(:modified_user_username) { 'modifiedtestusername' }
      let(:modified_user_password) { 'modified-test-password' }
      let(:update_params) do
        {
          'user': {
            'email': modified_user_email,
            'username': modified_user_username,
            'password': modified_user_password
          }
        }.to_json
      end
      let(:expected_response_body) do
        {
          'user': {
            'id': user_id,
            'createdAt': created_at.utc.to_s,
            'email': modified_user_email,
            'username': modified_user_username
          }
        }.to_json
      end

      subject do
        put '/user', params: update_params, headers: headers
      end

      it 'allows update action' do
        subject
        expect(response.status).to eq(200)
      end

      it 'displays updated user information' do
        subject
        expect(response.body).to eq(expected_response_body)
      end

      context 'with invalid update params' do
        context 'with invalid email format' do
          let(:modified_user_email) { 'modifiedtestgmail.com' }
          let(:error_response) do
            {
              "errors": {
                "email": [
                  'is not an email'
                ]
              }
            }.to_json
          end

          it 'renders bad_request status' do
            subject
            expect(response.status).to eq(400)
          end

          it 'renders a JSON error response' do
            subject
            expect(response.body).to eq(error_response)
          end
        end

        context 'with empty email' do
          let(:modified_user_email) { '' }
          let(:error_response) do
            {
              "errors": {
                "email": [
                  "can't be blank",
                  "is not an email"
                ]
              }
            }.to_json
          end

          it 'renders bad_request status' do
            subject
            expect(response.status).to eq(400)
          end

          it 'renders a JSON error response' do
            subject
            expect(response.body).to eq(error_response)
          end
        end

        context 'with empty username' do
          let(:modified_user_username) { '' }
          let(:error_response) do
            {
              "errors": {
                "username": [
                  "can't be blank",
                  'is invalid'
                ]
              }
            }.to_json
          end

          it 'renders bad_request status' do
            subject
            expect(response.status).to eq(400)
          end

          it 'renders a JSON error response' do
            subject
            expect(response.body).to eq(error_response)
          end
        end

        context 'with invalid password length below minimum limit' do
          let(:modified_user_password) { '12345' }
          let(:error_response) do
            {
              "errors": {
                "password": [
                  'is too short (minimum is 6 characters)'
                ]
              }
            }.to_json
          end

          it 'renders bad_request status' do
            subject
            expect(response.status).to eq(400)
          end

          it 'renders a JSON error response' do
            subject
            expect(response.body).to eq(error_response)
          end
        end

      context 'with invalid password length above maximum limit' do
        let(:modified_user_password) { 'a'*257}
        let(:error_response) do
          {
            "errors": {
              "password": [
                'is too long (maximum is 256 characters)'
              ]
            }
          }.to_json
        end

        it 'renders bad_request status' do
          subject
          expect(response.status).to eq(400)
        end

        it 'renders a JSON error response' do
          subject
          expect(response.body).to eq(error_response)
        end
      end
    end

      it_behaves_like 'a token with an invalid user_id payload'
    end

    context 'with DELETE /user request' do
      let(:expected_response_body) do
        {
          message: "Successfully deleted user #{user_username} with email #{user_email}"
        }.to_json
      end

      subject do
        delete '/user', params: {}, headers: headers
      end

      it 'allows delete action' do
        subject
        expect(response.status).to eq(200)
      end

      it 'displays user deletion message' do
        subject
        expect(response.body).to eq(expected_response_body)
      end

      it_behaves_like 'a token with an invalid user_id payload'

      context 'with no user to delete' do
        let(:invalid_id) { 123 }
        let(:not_user) do
          User.new(
            id: invalid_id,
            username: user_username,
            email: user_email,
            password: user_password
          )
        end
        let(:jwt_token) { not_user.generate_jwt }
        let(:headers) do
          {
            'Authorization' => "Token #{jwt_token}",
            'Content-Type' => 'application/json'
          }
        end
        let(:expected_error_message) do
          {
            'error': {
              'class': 'Exceptions::AuthenticationError::UserNotFound',
              'message': "ActiveRecord::RecordNotFound: Couldn't find user with id: #{invalid_id}"
            }
          }.to_json
        end

        subject do
          delete '/user', params: {}, headers: headers
        end

        it 'renders unauthorized error status' do
          subject
          expect(response.status).to eq(401)
        end

        it 'displays authentication error for deleting another user' do
          subject
          expect(response.body).to eq(expected_error_message)
        end

        it_behaves_like 'a token with an invalid user_id payload'
      end
    end
  end

  describe 'unauthenticated requests' do
    let(:jwt_token) { '' }

    context 'with POST /users request' do
      let(:headers) do
        {
          'Content-Type' => 'application/json'
        }
      end

      let(:user_email) { 'test@gmail.com' }
      let(:user_username) { 'testusername' }
      let(:user_password) { 'test-password' }
      let(:create_params) do
        {
          'user': {
            'email': user_email,
            'username': user_username,
            'password': user_password
          }
        }.to_json
      end

      let(:user_id) { User.last.id }
      let(:token_stub) { 'testtoken' }
      let(:expected_response_body) do
        {
          'user': {
            'id': user_id,
            'email': user_email,
            'token': token_stub,
            'username': user_username,
          }
        }.to_json
      end

      before do
        allow_any_instance_of(User).to receive(:generate_jwt).and_return(token_stub)
      end

      subject do
        post '/users', params: create_params, headers: headers
      end

      it 'successful create action' do
        subject
        expect(response.status).to eq(201)
      end

      it 'displays created user information' do
        subject
        expect(response.body).to eq(expected_response_body)
      end

      context 'with invalid email format' do
        let(:user_email) { 'invalidtestgmail.com' }
        let(:error_response) do
          {
            "errors": {
              "email": [
                'is not an email'
              ]
            }
          }.to_json
        end

        it 'renders bad_request status' do
          subject
          expect(response.status).to eq(400)
        end

        it 'renders a JSON error response' do
          subject
          expect(response.body).to eq(error_response)
        end
      end

      context 'with invalid username format' do
        let(:user_username) { 'invalid_test_username' }
        let(:error_response) do
          {
            "errors": {
              "username": [
                'is invalid'
              ]
            }
          }.to_json
        end

        it 'renders bad_request status' do
          subject
          expect(response.status).to eq(400)
        end

        it 'renders a JSON error response' do
          subject
          expect(response.body).to eq(error_response)
        end
      end

      context 'with invalid password length below minimum limit' do
        let(:user_password) { '12345' }
        let(:error_response) do
          {
            "errors": {
              "password": [
                'is too short (minimum is 6 characters)'
              ]
            }
          }.to_json
        end

        it 'renders bad_request status' do
          subject
          expect(response.status).to eq(400)
        end

        it 'renders a JSON error response' do
          subject
          expect(response.body).to eq(error_response)
        end
      end

      context 'with invalid password length above maximum limit' do
        let(:user_password) { 'a'*257 }
        let(:error_response) do
          {
            "errors": {
              "password": [
                'is too long (maximum is 256 characters)'
              ]
            }
          }.to_json
        end

        it 'renders bad_request status' do
          subject
          expect(response.status).to eq(400)
        end

        it 'renders a JSON error response' do
          subject
          expect(response.body).to eq(error_response)
        end
      end
    end

    context 'with POST /login request' do
      let(:headers) do
        {
          'Content-Type' => 'application/json'
        }
      end

      let(:user_id) { 1 }
      let(:user_username) { 'testusername' }
      let(:user_email) { 'test@gmail.com' }
      let(:user_password) { 'test-password' }
      let(:user) do
        FactoryBot.create(
          :user,
          id: user_id,
          username: user_username,
          email: user_email,
          password: user_password
        )
      end

      let(:token_stub) { 'testtoken' }
      let(:expected_response_body) do
        {
          'user': {
            'token': token_stub,
          }
        }.to_json
      end

      before do
        user
        allow_any_instance_of(User).to receive(:generate_jwt).and_return(token_stub)
      end

      context 'with valid email' do
        let(:login_params) do
          {
            'user': {
              'email': user_email,
              'password': user_password
            }
          }.to_json
        end

        subject do
          post '/login', params: login_params, headers: headers
        end

        it 'successful login action' do
          subject
          expect(response.status).to eq(200)
        end

        it 'displays generated JWT token for user' do
          subject
          expect(response.body).to eq(expected_response_body)
        end
      end

      context 'with valid username' do
        let(:login_params) do
          {
            'user': {
              'username': user_username,
              'password': user_password
            }
          }.to_json
        end

        subject do
          post '/login', params: login_params, headers: headers
        end

        it 'successful login action' do
          subject
          expect(response.status).to eq(200)
        end

        it 'displays generated JWT token for user' do
          subject
          expect(response.body).to eq(expected_response_body)
        end
      end

      context 'with invalid email' do
        let(:login_params) do
          {
            'user': {
              'email': 'invalidemail@gmail.com',
              'password': user_password
            }
          }.to_json
        end
        let(:expected_error_message) do
          {
            'error': 'invalid email, username, or password'
          }.to_json
        end

        subject do
          post '/login', params: login_params, headers: headers
        end

        it 'renders unauthorized login action' do
          subject
          expect(response.status).to eq(401)
        end

        it 'renders error message' do
          subject
          expect(response.body).to eq(expected_error_message)
        end
      end

      context 'with invalid username' do
        let(:login_params) do
          {
            'user': {
              'username': 'invalidusername',
              'password': user_password
            }
          }.to_json
        end
        let(:expected_error_message) do
          {
            'error': 'invalid email, username, or password'
          }.to_json
        end

        subject do
          post '/login', params: login_params, headers: headers
        end

        it 'renders unauthorized login action' do
          subject
          expect(response.status).to eq(401)
        end

        it 'renders error message' do
          subject
          expect(response.body).to eq(expected_error_message)
        end
      end
    end

    context 'with GET /user request' do
      let(:expected_response_body) do
        {
          'error': {
            'class': 'Exceptions::AuthenticationError::InvalidToken',
            'message': "JWT::DecodeError: Not enough or too many segments"
          }
        }.to_json
      end
      subject do
        get '/user', params: {}, headers: headers
      end

      it 'denys show action' do
        subject
        expect(response.status).to eq(401)
      end

      it 'does not display user information and renders access denied message' do
        subject
        expect(response.body).to eq(expected_response_body)
      end
    end

    context 'with PUT /user request' do
      let(:modified_user_email) { 'modifiedtest@gmail.com' }
      let(:modified_user_username) { 'modified_test_username' }
      let(:modified_user_password) { 'modified-test-password' }
      let(:update_params) do
        {
          'user': {
            'email': modified_user_email,
            'username': modified_user_username,
            'password': modified_user_password
          }
        }.to_json
      end
      let(:expected_response_body) do
        {
          'error': {
            'class': 'Exceptions::AuthenticationError::InvalidToken',
            'message': "JWT::DecodeError: Not enough or too many segments"
          }
        }.to_json
      end

      subject do
        put '/user', params: update_params, headers: headers
      end

      it 'denys update action' do
        subject
        expect(response.status).to eq(401)
      end

      it 'does not display updated user information and renders access denied message' do
        subject
        expect(response.body).to eq(expected_response_body)
      end
    end

    context 'with DELETE /user request' do
      let(:expected_response_body) do
        {
          'error': {
            'class': 'Exceptions::AuthenticationError::InvalidToken',
            'message': "JWT::DecodeError: Not enough or too many segments"
          }
        }.to_json
      end

      subject do
        delete '/user', params: {}, headers: headers
      end

      it 'denys delete action' do
        subject
        expect(response.status).to eq(401)
      end

      it 'does not display user deletion message and renders access denied message' do
        subject
        expect(response.body).to eq(expected_response_body)
      end
    end
  end
end
