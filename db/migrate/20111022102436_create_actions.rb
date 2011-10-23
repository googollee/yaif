class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.string :name
      t.text :description
      t.string :uri
      t.text :do
      t.references :service

      t.timestamps
    end
    add_index :actions, :service_id
  end
end
