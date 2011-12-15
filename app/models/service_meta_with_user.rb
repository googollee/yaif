class ServiceMetaWithUser < ActiveRecord::Base
  set_table_name "service_meta_with_user"

  validates :user, :presence => true
  validates :service, :presence => true

  belongs_to :service
  belongs_to :user

  def data
    ActiveSupport::JSON.decode(super).sybmolize_keys! rescue nil
  end

  def data=(d)
    super d.to_json
  end
end
