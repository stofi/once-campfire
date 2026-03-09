require "test_helper"

class Api::RoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bot = users(:bender)
  end

  test "list rooms with valid token" do
    get api_rooms_url, headers: bearer_headers(@bot)
    assert_response :success

    rooms = JSON.parse(response.body)
    room_names = rooms.map { |r| r["name"] }
    assert_includes room_names, "All Talk"
    assert_includes room_names, "HQ"
  end

  test "list rooms includes permission flags" do
    get api_rooms_url, headers: bearer_headers(@bot)
    rooms = JSON.parse(response.body)

    watercooler = rooms.find { |r| r["name"] == "All Talk" }
    assert watercooler["can_read"]
    assert watercooler["can_write"]

    hq = rooms.find { |r| r["name"] == "HQ" }
    assert hq["can_read"]
    refute hq["can_write"]
  end

  test "list rooms includes direct rooms with full access" do
    get api_rooms_url, headers: bearer_headers(@bot)
    rooms = JSON.parse(response.body)

    direct = rooms.find { |r| r["type"] == "direct" }
    assert direct
    assert direct["can_read"]
    assert direct["can_write"]
  end

  test "unauthorized without token" do
    get api_rooms_url
    assert_response :unauthorized
  end

  test "unauthorized with bad token" do
    get api_rooms_url, headers: { "Authorization" => "Bearer bad-token" }
    assert_response :unauthorized
  end

  private
    def bearer_headers(bot)
      { "Authorization" => "Bearer #{bot.bot_key}" }
    end
end
