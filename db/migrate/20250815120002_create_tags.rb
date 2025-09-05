class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.string :token, null: false
      t.references :table, null: false, foreign_key: true
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :tags, :token, unique: true
  end
end

