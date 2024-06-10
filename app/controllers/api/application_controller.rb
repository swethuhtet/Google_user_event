class Api::ApplicationController < ApplicationController
    
  def authenticated_user
    userEmail = request.headers['Email']
    userPassword = request.headers['Password']

    if userEmail.present? && userPassword.present?
        @user = find_user(email: userEmail)
        unless @user && @user.encrypted_password == userPassword
          render json: { error: 'Authentication failed. Invalid email or password.'}, status: :unauthorized 
        end
    else
      render json: { error: 'Email and Password should not be null' }, status: :unauthorized
    end
  end

  private
  def find_user(param)
    @user = User.find_by(param) 
  end
end
