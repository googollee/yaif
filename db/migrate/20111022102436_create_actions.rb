class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.string :name, :unique => true
      t.text :description
      t.string :http_type
      t.string :http_method
      t.text :in_keys
      t.string :target
      t.text :body
      t.references :service

      t.timestamps
    end
    add_index :actions, :service_id
  end
end
