class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.references :user
      t.references :trigger
      t.text :trigger_params
      t.references :action
      t.text :action_params

      t.timestamps
    end
    add_index :tasks, :user_id
    add_index :tasks, :trigger_id
    add_index :tasks, :action_id
  end
end
