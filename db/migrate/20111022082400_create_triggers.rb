class CreateTriggers < ActiveRecord::Migration
  def change
    create_table :triggers do |t|
      t.string :name, :unique => true
      t.text :description
      t.string :http_type
      t.string :http_method
      t.string :period
      t.text :in_keys
      t.string :source
      t.text :header
      t.text :out_keys
      t.text :content_to_hash
      t.references :service

      t.timestamps
    end
    add_index :triggers, :service_id
  end
end
