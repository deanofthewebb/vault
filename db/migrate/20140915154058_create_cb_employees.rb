class CreateCbEmployees < ActiveRecord::Migration

  def change
    create_table :cb_employees do |t|
      t.string :full_name
      t.string :employee_id
      t.string :network_name
      t.string :job_title
      t.boolean :is_manager
      t.string :email
      t.text :manager
      t.text :coworker
      t.text :subordinates
      t.text :additional_members

      t.timestamps
    end
    add_index :cb_employees, [:full_name, :employee_id], unique: true
  end
end
