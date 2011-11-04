class Service < ActiveRecord::Base
  validates :name, :presence => true,
                   :length => { :maximum => 200 }
  validates :icon, :presence => true
  validates :auth_type, :presence => true

  serialize :auth_data, Hash

  has_many :triggers
  has_many :actions
  has_many :service_meta_with_user

  def auth
    AuthHelper.send("#{self.auth_type}_auth", self)
  end

  def save_meta(user, data)
    meta = ServiceMetaWithUser.create!(:service => self, :user => user, :data => data)
  end

  def meta(user)
    metas = ServiceMetaWithUser.where :service_id => self, :user_id => user
    meta = metas[0] ? metas[0].data : {}
    meta[:auth_data] = auth_data || {}
    meta
  end

  def inner_runtime(params = nil)
    inner = InnerRuntime.new params
    inner.instance_eval self.helper
    inner
  end

  private

  class InnerRuntime
    def initialize(params)
      @params = params
    end

    def eval(str)
      instance_eval str
    end

    def method_missing(m, *args, &block)
      return self.send(m, *args, &block) if self.respond_to? m
      return @params[m] if @params and @params.include? m
      super
    end
  end
end
