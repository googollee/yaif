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

  def get_body(user, *args)
    init_env user, args
    @params[:content] = RequestHelper.send "#{http_type}_request".to_sym, http_method.to_sym, uri, "", meta
  end

  def get(user, *args)
    get_body user, *args
    @runtime.eval content_to_hash
  end

  private

  def init_env(user, args)
    @params = args[-1] || {}
    @runtime = service.inner_runtime @params
    @user = user
  end

  def meta
    service.meta @user
  end

  def uri
    @runtime.eval "\"#{source}\""
  end
end
