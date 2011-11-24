class CreateRegKeys < ActiveRecord::Migration
  def change
    create_table :reg_keys do |t|
      t.string :key, :unique => true
      t.string :email, :unique => true
      t.integer :validation, :default => 1

      t.timestamps
    end
  end
end
