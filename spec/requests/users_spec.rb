require 'swagger_helper'

RSpec.describe '/users', type: :request do
  path '/users' do
    post 'Creates a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          username: { type: :string },
          password: { type: :string }
        },
        required: ['email', 'username', 'password']
      }

      response '201', 'user created' do
        schema type: :object,
          properties: {
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                created_at: { type: :string },
                email: { type: :string },
                username: { type: :string },
                token: { type: :string }
              }
            }
          }

        let(:user) do
          {
            user: {
              email: 'testemail@gmail.com',
              username: 'testusername',
              password: 'testpassword'
            }
          }
        end

        run_test!
      end

      response '400', 'invalid request' do
        let(:user) do
          {
            user: {
              email: 'testemailgmail.com',
              username: 'test/username',
              password: 'test'
            }
          }
        end

        run_test!
      end
    end
  end

  path '/login' do
    post 'Logs a user in with a username' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          username: { type: :string },
          password: { type: :string }
        },
        required: ['username', 'password']
      }

      let(:user_username) { 'testusername' }
      let(:user_password) { 'testpassword' }
      before do
        FactoryBot.create(
          :user,
          username: user_username,
          password: user_password
        )
      end

      response '200', 'user logged in successfully' do
        schema type: :object,
          properties: {
            user: {
              type: :object,
              properties: {
                token: { type: :string }
              }
            }
          }

        let(:user) do
          {
            user: {
              username: user_username,
              password: user_password
            }
          }
        end

        run_test!
      end

      response '401', 'unauthorized' do
        let(:user) do
          {
            user: {
              username: user_username,
              password: "invalid#{user_password}"
            }
          }
        end

        run_test!
      end
    end
  end

  path '/login' do
    post 'Logs a user in with an email' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: ['email', 'password']
      }

      let(:user_email) { 'testemail@gmail.com' }
      let(:user_password) { 'testpassword' }
      before do
        FactoryBot.create(
          :user,
          email: user_email,
          password: user_password
        )
      end

      response '200', 'user logged in successfully' do
        schema type: :object,
          properties: {
            user: {
              type: :object,
              properties: {
                token: { type: :string }
              }
            }
          }
          
        let(:user) do
          {
            user: {
              username: user_email,
              password: user_password
            }
          }
        end

        run_test!
      end

      response '401', 'unauthorized' do
        let(:user) do
          {
            user: {
              username: user_email,
              password: "invalid#{user_password}"
            }
          }
        end

        run_test!
      end
    end
  end

  path '/user' do
    get 'Retrieves the current user\'s data' do
      tags 'User'
      produces 'application/json'
      security [Token: {}]

      let(:user) do
        FactoryBot.create(:user)
      end
      let(:jwt_token) { user.generate_jwt }

      response '200', 'user found' do
        schema type: :object,
          properties: {
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                created_at: { type: :string },
                email: { type: :string },
                username: { type: :string }
              }
            }
          }

        let(:Authorization) { "Token #{jwt_token}" }

        run_test!
      end

      response '401', 'current user not authenticated' do
        let(:Authorization) { 'Invalid token' }

        run_test!
      end
    end

    put 'Updates the current user\'s data' do
      tags 'User'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          username: { type: :string },
          password: { type: :string }
        }
      }
      security [Token: {}]

      let(:generated_user) do
        FactoryBot.create(:user)
      end
      let(:jwt_token) { generated_user.generate_jwt }

      let(:user) do
        {
          user: {
            email: 'testemailmodified@gmail.com',
            username: 'testusernamemodified',
            password: 'testpasswordmodified'
          }
        }
      end

      response '200', 'user updated' do
        schema type: :object,
          properties: {
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                created_at: { type: :string },
                email: { type: :string },
                username: { type: :string }
              }
            }
          }

        let(:Authorization) { "Token #{jwt_token}" }

        run_test!
      end

      response '401', 'current user not authenticated' do
        let(:Authorization) { 'Invalid token' }

        run_test!
      end
    end

    delete 'Deletes the current user' do
      tags 'User'
      produces 'application/json'
      security [Token: {}]

      let(:user) do
        FactoryBot.create(:user)
      end
      let(:jwt_token) { user.generate_jwt }

      response '200', 'user deleted' do
        let(:Authorization) { "Token #{jwt_token}" }

        run_test!
      end

      response '401', 'current user not authenticated' do
        let(:Authorization) { 'Invalid token' }

        run_test!
      end
    end
  end
end
