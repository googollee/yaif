class Service < ActiveRecord::Base
  attr_accessible :name, :icon, :description, :auth_type, :auth_data, :helper

  validates :name, :presence => true,
                   :length => { :maximum => 200 }
  validates :icon, :presence => true
  validates :auth_type, :presence => true

  serialize :auth_data, SymbolHashJSONCoder.new

  has_many :triggers
  has_many :actions
  has_many :service_meta_with_user

  def auth(session, callback_url)
    AuthHelper.send("#{auth_type}_auth", self, session, callback_url)
  end

  def auth_meta(user, session, params)
    data = AuthHelper.send("#{auth_type}_get_meta", self, session, params)
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
