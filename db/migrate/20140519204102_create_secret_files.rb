class CreateSecretFiles < ActiveRecord::Migration
  def self.up
    create_table :secret_files do |t|
      t.string :file_name
      t.string :environment 
      t.string :role
      t.string :secret_key
      t.string :login
      t.timestamps
     end

    add_index :secret_files, [:file_name, :environment], unique: true
  end
  
  def self.down
    drop_table :secret_files
  end
end
