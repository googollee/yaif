class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name
      t.text :description
      t.string :auth_uri
      t.string :auth_type
      t.text :auth_data

      t.timestamps
    end
  end
end
