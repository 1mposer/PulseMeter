class AddMissingUniqueIndexes < ActiveRecord::Migration[8.0]
  def change
    # Fix Issue: Members.email uniqueness validation without DB index (race condition vulnerability)
    add_index :members, :email, unique: true, name: 'index_members_on_email_unique'

    # Fix Issue: Tables.name uniqueness validation without DB index (race condition vulnerability)
    add_index :tables, :name, unique: true, name: 'index_tables_on_name_unique'
  end

  def down
    remove_index :members, name: 'index_members_on_email_unique'
    remove_index :tables, name: 'index_tables_on_name_unique'
  end
end