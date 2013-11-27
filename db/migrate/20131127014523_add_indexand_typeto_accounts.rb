class AddIndexandTypetoAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :user_id, :integer
    add_column :accounts, :type_of_account, :string
    add_index :accounts, [:user_id, :created_at]
  end
end
