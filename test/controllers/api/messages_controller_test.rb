require "test_helper"

class Api::MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bot = users(:bender)
    @room = rooms(:watercooler)
  end

  test "list messages with read permission" do
    get api_room_messages_url(@room), headers: bearer_headers(@bot)
    assert_response :success

    messages = JSON.parse(response.body)
    assert messages.is_a?(Array)
  end

  test "list messages with since filter" do
    get api_room_messages_url(@room), headers: bearer_headers(@bot), params: { since: 1.hour.ago.iso8601 }
    assert_response :success
  end

  test "post message with write permission" do
    assert_difference -> { Message.count }, +1 do
      post api_room_messages_url(@room), headers: bearer_headers(@bot),
        params: { body: "Hello from the API!" }, as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Hello from the API!", json["body"]
  end

  test "forbidden when no read permission" do
    room = rooms(:designers)
    get api_room_messages_url(room), headers: bearer_headers(@bot)
    assert_response :forbidden
  end

  test "forbidden when no write permission on read-only room" do
    room = rooms(:hq)
    post api_room_messages_url(room), headers: bearer_headers(@bot),
      params: { body: "Should fail" }, as: :json
    assert_response :forbidden
  end

  test "not found for nonexistent room" do
    get api_room_messages_url(room_id: 999999), headers: bearer_headers(@bot)
    assert_response :not_found
  end

  test "unauthorized without token" do
    get api_room_messages_url(@room)
    assert_response :unauthorized
  end

  private
    def bearer_headers(bot)
      { "Authorization" => "Bearer #{bot.bot_key}" }
    end
end
