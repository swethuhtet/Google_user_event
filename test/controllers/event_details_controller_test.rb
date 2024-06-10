require "test_helper"

class EventDetailsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get event_details_index_url
    assert_response :success
  end

  test "should get show" do
    get event_details_show_url
    assert_response :success
  end

  test "should get create" do
    get event_details_create_url
    assert_response :success
  end
end
