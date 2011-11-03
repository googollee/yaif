class Trigger < ActiveRecord::Base
  validates :name, :presence => true,
                   :length => { :maximum => 200 }
  validates :http_type, :presence => true
  validates :http_method, :presence => true
  validates :source, :presence => true
  validates :out_keys, :presence => true

  validates :service, :presence => true

  serialize :in_keys, Array
  serialize :out_keys, Array

  belongs_to :service

  has_many :tasks

  def get_atom(user, *args)
    init_env user, args
    content = RequestHelper.send "#{self.http_type}_request".to_sym, self.http_method.to_sym, uri, "", meta
    @convert_to_hash ||= eval "lambda { |content| #{self.content_to_hash} }"
    @convert_to_hash.call content
  end

  def method_missing(m, *arg, &block)
    return self.send(m, *arg, &block) if self.respond_to?(m)
    self.service.send(m, *arg, &block)
  end

  private

  def init_env(user, args)
    @params = args[-1] || {}
    @init_str = @params.each.inject("") { |o, kv| o + "#{kv[0]} = \"#{kv[1]}\"" }
    @user = user
  end

  def meta
    ServiceMetaWithUser.get self.service, @user
  end

  def uri
    instance_eval "#{@init_str}\n\"#{self.source}\""
  end
end
