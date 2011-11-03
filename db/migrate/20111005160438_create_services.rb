class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name, :unique => true
      t.text :description
      t.string :icon
      t.string :auth_type
      t.text :auth_data
      t.text :helper

      t.timestamps
    end
  end
end
