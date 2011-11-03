class CreateServiceMetaWithUser < ActiveRecord::Migration
  def change
    create_table :service_meta_with_user do |t|
      t.references :service
      t.references :user
      t.text :data

      t.timestamps
    end
    add_index :service_meta_with_user, :service_id
    add_index :service_meta_with_user, :user_id
    add_index :service_meta_with_user, [:service_id, :user_id], :unique => true
  end
end
