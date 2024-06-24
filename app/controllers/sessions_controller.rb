class SessionsController < ApplicationController

    #call back after auth
    def googleAuth
        user_info = request.env['omniauth.auth']
        email = user_info.info.email
        google_token = user_info.credentials.token
        google_refresh_token = user_info.credentials.refresh_token
        byebug
        expires_in = user_info.credentials.expires_in
        expires_at = Time.current + expires_in.to_i.seconds 

        user = User.find_by(email: email)

        user.update(google_token: google_token, google_refresh_token: google_refresh_token, expires_at: expires_at)

        redirect_to user_path(user), notice: 'Logged in with Google successfully!'
    end

    #delete token after revoke_google_token
    def cancel_google_oauth2
        user = User.find(params[:id])

        if user.google_token.present?
        revoke_google_token(user.google_token)

        user.update(google_token: nil, google_refresh_token: nil,expires_at: nil)
        flash[:notice] = "Google login canceled and tokens revoked."
        else
        flash[:alert] = "No Google OAuth token found."
    end
    
    redirect_to user_path(user)
end

private

def revoke_google_token(token)
    uri = URI("https://accounts.google.com/o/oauth2/revoke?token=#{token}")
    Net::HTTP.get_response(uri)
    rescue StandardError => e
        flash[:alert] = "Failed to revoke token."
        Rails.logger.error("Failed to revoke token: #{e.message}")
    end
end
