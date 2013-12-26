class CreateComps < ActiveRecord::Migration
  def change
    create_table :comps do |t|
      t.integer :user_id
      t.integer :account_id
      t.string :description
      t.string :expiration
      t.string :days_until_expiration

      t.timestamps
    end
  end
end
