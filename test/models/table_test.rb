require 'test_helper'

class TableTest < ActiveSupport::TestCase
  test "should create table with default_price_per_minute" do
    table = Table.new(name: "Test Table", active: true, default_price_per_minute: 0.75)
    assert table.valid?
    assert table.save
    
    assert_equal 0.75, table.default_price_per_minute.to_f
    assert_equal "Test Table", table.name
    assert table.active?
  end

  test "should require name" do
    table = Table.new(active: true, default_price_per_minute: 0.50)
    assert_not table.valid?
    assert_includes table.errors[:name], "can't be blank"
  end

  test "should have sensible default_price_per_minute from migration" do
    table = Table.create!(name: "Test Table", active: true)
    # After migration, this should have the default value of 0.50
    assert_equal 0.50, table.default_price_per_minute.to_f
  end
end