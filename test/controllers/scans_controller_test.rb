require 'test_helper'

class ScansControllerTest < ActionDispatch::IntegrationTest
  def setup
    @table = Table.create!(name: "Test Table", active: true, default_price_per_minute: 0.50)
    @tag = Tag.create!(token: "TEST123", table: @table, active: true)
  end

  test "should open session with explicit price_per_minute" do
    post "/scan/TEST123/open.json", 
         params: { session: { price_per_minute: 0.75 } },
         headers: { "Content-Type": "application/json", "Accept": "application/json" }
    
    assert_response :created
    
    json_response = JSON.parse(response.body)
    assert_equal "0.75", json_response["price_per_minute"]
    assert_equal "open", json_response["status"]
    assert_equal @table.id, json_response["table"]["id"]
    assert_equal @tag.token, json_response["tag"]["token"]
    
    # Verify session was created with correct price
    session = Session.last
    assert_equal 0.75, session.price_per_minute.to_f
    assert_equal @table.id, session.table_id
    assert_equal @tag.id, session.tag_id
    assert_equal "scan", session.opened_via
  end

  test "should open session using table default_price_per_minute when no price provided" do
    post "/scan/TEST123/open.json",
         params: {},
         headers: { "Content-Type": "application/json", "Accept": "application/json" }
    
    assert_response :created
    
    json_response = JSON.parse(response.body)
    assert_equal "0.50", json_response["price_per_minute"]
    assert_equal "open", json_response["status"]
    
    # Verify session was created with table default price
    session = Session.last
    assert_equal 0.50, session.price_per_minute.to_f
    assert_equal @table.id, session.table_id
  end

  test "should return existing session when table already has open session" do
    # Create an existing open session
    existing_session = Session.create!(
      table_id: @table.id,
      tag_id: @tag.id,
      time_in: 1.hour.ago,
      price_per_minute: 0.60,
      opened_via: "scan"
    )
    
    post "/scan/TEST123/open.json",
         params: { session: { price_per_minute: 0.75 } },
         headers: { "Content-Type": "application/json", "Accept": "application/json" }
    
    assert_response :ok
    
    json_response = JSON.parse(response.body)
    assert_equal existing_session.id, json_response["id"]
    assert_equal "0.60", json_response["price_per_minute"]
    
    # Verify no new session was created
    assert_equal 1, Session.count
  end

  test "should fail gracefully with invalid tag" do
    post "/scan/INVALID/open.json",
         params: {},
         headers: { "Content-Type": "application/json", "Accept": "application/json" }
    
    assert_response :not_found
    
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Tag not found"
  end

  test "should fail gracefully with inactive tag" do
    @tag.update!(active: false)
    
    post "/scan/TEST123/open.json",
         params: {},
         headers: { "Content-Type": "application/json", "Accept": "application/json" }
    
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Tag is inactive"
  end
end