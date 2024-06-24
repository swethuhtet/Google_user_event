require 'google/apis/calendar_v3'
require 'google/api_client/client_secrets.rb'

class GoogleService
  def initialize(user)
    @user = user 
    Google::Apis.logger.level = Logger::DEBUG
  end

  #CREATE event in calendar
  def create_event(event)
    client = setup_google_client
    client.insert_event('primary', event)
  rescue Google::Apis::ClientError => e
    Rails.logger.error("Failed to create Google Calendar event: #{e.message}")
    Rails.logger.error("Response body: #{e.body}")
    nil
  end

  #UPDATE event in calendar
  def update_event(event_detail, event)
    client = setup_google_client
    client.update_event('primary', event_detail.google_calendar_id ,event)
  rescue Google::Apis::ClientError => e
    Rails.logger.error("Failed to update Google Calendar event: #{e.message}")
    Rails.logger.error("Response body: #{e.body}")
    nil
  end

  #DELETE event in calendar
  def delete_event(event_detail)
    client = setup_google_client
    client.delete_event('primary', event_detail.google_calendar_id)
  rescue Google::Apis::ClientError => e
    Rails.logger.error("Failed to update Google Calendar event: #{e.message}")
    Rails.logger.error("Response body: #{e.body}")
    nil
  end

  #call service as a client
  def setup_google_client
    client = Google::Apis::CalendarV3::CalendarService.new
    secrets = Google::APIClient::ClientSecrets.new({
      "web" => {
        "access_token" => @user.google_token,
        "refresh_token" => @user.google_refresh_token,
        "client_id" => ENV["GOOGLE_CLIENT_ID"],
        "client_secret" => ENV["GOOGLE_CLIENT_SECRET"]  
      }
    })
    client.authorization = secrets.to_authorization 

    #refresh token if token expired
    refresh_google_token(client) if @user.access_token_expired? 
       
    #return
    client
  end


private

  def refresh_google_token(client)
      begin
        refresh_resp = client.authorization.refresh!
        @user.update(
          google_token: refresh_resp["access_token"],
          expires_at: Time.current + refresh_resp["expires_in"].to_i.seconds
          )
        true
      rescue => e
        Rails.logger.error("Failed to refresh Google token: #{e.message}")
        false
      end
  end
end