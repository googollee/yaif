class ServiceMetaWithUser < ActiveRecord::Base
  set_table_name "service_meta_with_user"

  validates :user, :presence => true
  validates :service, :presence => true

  serialize :data, Hash

  belongs_to :service
  belongs_to :user

  def self.get(service, user)
    meta = self.where :service_id => service, :user_id => user
    meta[0] ? meta[0].data : nil
  end
end
