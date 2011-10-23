class CreateTriggers < ActiveRecord::Migration
  def change
    create_table :triggers do |t|
      t.string :name
      t.text :description
      t.string :uri
      t.text :do
      t.references :service

      t.timestamps
    end
    add_index :triggers, :service_id
  end
end
