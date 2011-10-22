class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name
      t.string :description
      t.string :auth_uri
      t.string :auth_type
      t.binary :auth_data

      t.timestamps
    end
  end
end
