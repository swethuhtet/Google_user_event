require 'rails_helper'

RSpec.describe "Guests", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/guests/index"
      expect(response).to have_http_status(:success)
    end
  end

end
