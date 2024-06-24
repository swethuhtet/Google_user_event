require 'rails_helper'

RSpec.describe 'Users API', type: :request do

  describe 'GET /users' do
    it 'returns a list of users' do
      get '/users'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /users/:id' do
    it 'returns the user' do 
      existing_user = User.first

      get "/users/#{existing_user.id}" 
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /users' do
    context 'when creating a new user' do
      let(:valid_user_params) do
        {
          user: {
            firstname: "John",
            lastname: "Doe",
            email: "test123@email.com",
            encrypted_password: "password1",
            about_me: "New user",
            profile: nil,
            gender: 0
          }
        }
      end

      it 'creates a new user' do   
        expect {
          post '/users', params: valid_user_params, headers: { 'ACCEPT' => 'application/json' }
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created) 
        expect(User.last.firstname).to eq('John')        
        expect(User.last.email).to eq('test123@email.com')
      end

      it 'returns an error if firstname is blank' do
        invalid_user_params = valid_user_params.deep_merge(user: { firstname: "" })

        expect {
          post '/users', params: invalid_user_params, headers: { 'ACCEPT' => 'application/json' }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response).to include("errors")  
        expect(json_response["errors"]["firstname"]).to include("First name cannot be empty")
      end

      it 'returns an error if email is blank' do
        invalid_user_params = valid_user_params.deep_merge(user: { email: "" })

        expect {
          post '/users', params: invalid_user_params, headers: { 'ACCEPT' => 'application/json' }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response).to include("errors")  
        expect(json_response["errors"]["email"]).to include("Email cannot be empty")
      end

      it 'returns an error if password is blank' do
        invalid_user_params = valid_user_params.deep_merge(user: { encrypted_password: "" })

        expect {
          post '/users', params: invalid_user_params, headers: { 'ACCEPT' => 'application/json' }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response).to include("errors")  
        expect(json_response["errors"]["encrypted_password"]).to include("Password cannot be empty")
      end
    end
  end

  describe 'PATCH /users/:id' do 
    let(:existing_user) { User.first }

    context 'when updating an existing user' do
      it 'updates user attributes' do
        user_params = {
          user: {
            firstname: "Updated Firstname",
            lastname: "Updated Lastname",
            email: "updated_email@example.com",
            encrypted_password: "password1",
            about_me: "Updated about me",
            profile: nil,
            gender: 0
          }
        }

        patch "/users/#{existing_user.id}", params: user_params
        
        expect(response).to have_http_status(:found) 

        updated_user = existing_user.reload

        expect(updated_user.firstname).to eq("Updated Firstname") 
        expect(updated_user.lastname).to eq("Updated Lastname")
        expect(updated_user.email).to eq("updated_email@example.com")
        expect(updated_user.about_me).to eq("Updated about me")
      end

      it 'returns error if firstname is blank' do
        invalid_params = {
          user: {
            firstname: "",
            lastname: "Updated Lastname",
            email: "updated_email@example.com",
            encrypted_password: "password1",
            about_me: "Updated about me",
            profile: nil,
            gender: 0
          }
        }

        patch "/users/#{existing_user.id}", params: invalid_params, headers: { 'ACCEPT' => 'application/json' }
        
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response).to include("errors")  
        expect(json_response["errors"]["firstname"]).to include("First name cannot be empty")
      end

      it 'returns error if email is blank' do
        invalid_params = {
          user: {
            firstname: "Updated Firstname",
            lastname: "Updated Lastname",
            email: "",
            encrypted_password: "password1",
            about_me: "Updated about me",
            profile: nil,
            gender: 0
          }
        }

        patch "/users/#{existing_user.id}", params: invalid_params, headers: { 'ACCEPT' => 'application/json' }
        
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response).to include("errors")  
        expect(json_response["errors"]["email"]).to include("Email cannot be empty")
      end
    end

    context 'when user does not exist' do
      it 'returns not found status' do
        invalid_user_id = existing_user.id + 1000

        patch "/users/#{invalid_user_id}"
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /users/:id' do
    let!(:user_to_delete) { User.first } 

    context 'when user exists' do
      it 'deletes the user' do
        expect {
          delete "/users/#{user_to_delete.id}"
        }.to change(User, :count).by(-1)

        expect(response).to redirect_to(users_url)
        follow_redirect!
        
        expect(flash[:notice]).to eq(I18n.t('messages.common.destroy_success', data: "User"))
      end

      it 'returns a success JSON response' do
        delete "/users/#{user_to_delete.id}", headers: { 'ACCEPT' => 'application/json' }
        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_empty
      end
    end

    context 'when user does not exist' do
      it 'returns not found status' do
        delete "/users/#{user_to_delete.id + 1000}" 

        expect(response).to have_http_status(:not_found)
        expect(response.body).to include('User not found')
      end

      it 'returns a JSON error response' do
        delete "/users/#{user_to_delete.id + 1000}", headers: { 'ACCEPT' => 'application/json' }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

end