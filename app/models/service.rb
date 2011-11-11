class Service < ActiveRecord::Base
  validates :name, :presence => true,
                   :length => { :maximum => 200 }
  validates :icon, :presence => true
  validates :auth_type, :presence => true

  serialize :auth_data, Hash

  has_many :triggers
  has_many :actions
  has_many :service_meta_with_user

  def auth(session)
    AuthHelper.send("#{auth_type}_auth", self, session)
  end

  def auth_meta(user, session)
    data = AuthHelper.send("#{auth_type}_get_meta", self, session)
    metas = ServiceMetaWithUser.where :service_id => self, :user_id => user
    return ServiceMetaWithUser.create!(:service => self, :user => user, :data => data) if metas.length == 0
    metas[0].update_attributes! :data => data
  end

  def meta(user)
    metas = ServiceMetaWithUser.where :service_id => self, :user_id => user
    return nil if metas.length == 0
    metas[0].data
  end

  def inner_runtime(params = nil)
    inner = RuntimeHelper::InnerRuntime.new
    inner.add_params params if params
    inner.instance_eval self.helper if self.helper
    inner
  end
end
