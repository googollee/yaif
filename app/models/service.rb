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
    meta = AuthHelper.send("#{auth_type}_get_meta", self, session)
    ServiceMetaWithUser.create!(:service => self, :user => user, :data => meta)
  end

  def meta(user)
    metas = ServiceMetaWithUser.where :service_id => self, :user_id => user
    meta = metas[0] ? metas[0].data : {}
    meta[:auth_data] = auth_data || {}
    meta
  end

  def inner_runtime(params = nil)
    inner = RuntimeHelper::InnerRuntime.new self.helper, params
    inner
  end
end
