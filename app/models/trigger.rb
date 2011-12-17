class Trigger < ActiveRecord::Base
  validates :name, :presence => true,
                   :length => { :maximum => 200 }
  validates :http_type, :presence => true
  validates :http_method, :presence => true
  validates :source, :presence => true
  validates :out_keys, :presence => true

  validates :service, :presence => true

  serialize :in_keys, JSONCoder.new([])
  serialize :header, JSONCoder.new({})
  serialize :out_keys, JSONCoder.new([])

  belongs_to :service

  has_many :tasks

  def get_body(user, params)
    init_env user, params
    content = RequestHelper.send("#{http_type}_request".to_sym, http_method.to_sym, uri, nil, meta)
    @runtime.add_params :content => content
    content
  end

  def get(user, params)
    get_body user, params
    @runtime.eval content_to_hash
  end

  private

  def init_env(user, params)
    @runtime = service.inner_runtime params || {}
    @user = user
  end

  def meta
    ret = service.meta(@user)
    raise "Need register service(#{service.name}) first" unless ret
    ret.merge! :header => header
  end

  def uri
    @runtime.eval "\"#{source}\""
  end
end
