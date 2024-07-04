require 'csv'
class User < ApplicationRecord
    has_one_attached :profile
    has_many :event_details,  dependent: :destroy 

    def image_url
        Rails.application.routes.url_helpers.url_for(profile) if profile.attached?
    end

    def access_token_expired?    
        expires_at.nil? ? false : expires_at < Time.current
    end

    def self.import(file)
      CSV.foreach(file.path, headers:true) do |row|
        user_params = row.to_hash
        User.create!(user_params)
      end
    end
end
