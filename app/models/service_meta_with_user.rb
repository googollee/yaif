class ServiceMetaWithUser < ActiveRecord::Base
  set_table_name "service_meta_with_user"

  validates :user, :presence => true
  validates :service, :presence => true

  serialize_json :data

  belongs_to :service
  belongs_to :user
end
