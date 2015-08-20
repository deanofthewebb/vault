class CreateSecretLinks < ActiveRecord::Migration
  def change
    create_table :secret_links do |t|
      t.string :username
      t.string :added_users
      t.boolean :blessed

      t.timestamps
    end
    add_index :secret_links, [:username, :added_users],	unique: true
  end
end
