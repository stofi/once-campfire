require "test_helper"

class Api::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bot = users(:bender)
  end

  test "list users" do
    get api_users_url, headers: bearer_headers(@bot)
    assert_response :success

    users = JSON.parse(response.body)
    assert users.is_a?(Array)
    assert users.any? { |u| u["name"] == "David" && u["bot"] == false }
    assert users.any? { |u| u["name"] == "Bender Bot" && u["bot"] == true }
  end

  test "unauthorized without token" do
    get api_users_url
    assert_response :unauthorized
  end

  private
    def bearer_headers(bot)
      { "Authorization" => "Bearer #{bot.bot_key}" }
    end
end
