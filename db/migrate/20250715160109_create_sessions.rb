class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.datetime :time_in
      t.datetime :time_out
      t.integer :membership_id
      t.decimal :price_per_minute

      t.timestamps
    end
  end
end
