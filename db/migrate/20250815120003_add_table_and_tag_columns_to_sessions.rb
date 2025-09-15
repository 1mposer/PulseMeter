class AddTableAndTagColumnsToSessions < ActiveRecord::Migration[8.0]
  def change
    add_reference :sessions, :table, null: true, foreign_key: true
    add_reference :sessions, :tag, null: true, foreign_key: true
    add_column :sessions, :opened_via, :string, null: true
    add_column :sessions, :voided_at, :datetime, null: true
    add_column :sessions, :void_reason, :text, null: true
  end
end

