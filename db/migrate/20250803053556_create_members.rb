class CreateMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :members do |t|
      t.string :email
      t.string :total_spent_sessions

      t.timestamps
    end
  end
end
