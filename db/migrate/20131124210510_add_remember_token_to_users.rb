class AddRememberTokenToUsers < ActiveRecord::Migration
  def change
    remove_column :users, :remember_token
    add_column :users, :remember_token, :string
    add_index :users, :remember_token
  end
end
