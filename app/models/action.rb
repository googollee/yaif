class Action < ActiveRecord::Base
  validates :name, :presence => true,
                   :length => { :maximum => 200 }
  validates :http_type, :presence => true
  validates :http_method, :presence => true
  validates :target, :presence => true

  validates :service, :presence => true

  serialize :in_keys, Array

  belongs_to :service

  has_many :tasks

  def send_request(user, params)
    init_env user, params
    RequestHelper.send "#{self.http_type}_request".to_sym, self.http_method.to_sym, uri, body_, meta
  end

  def method_missing(m, *args, &block)
    return self.send(m, *args, &block) if self.respond_to? m
    return @params[m] if @params and @params.include? m
    self.service.send(m, *args, &block)
  end

  private

  def init_env(user, params)
    @params = params || {}
    @init_str = @params.each.inject("") { |o, kv| o += "#{kv[0]} = \"#{kv[1]}\"\n" }
    @user = user
  end

  def uri
    MetaHelper.hash_eval @params, "\"#{self.target}\""
  end

  def body_
    eval self.body
  end

  def meta
    ServiceMetaWithUser.get self.service, @user
  end
end
