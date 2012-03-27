class Trigger < ActiveRecord::Base
  attr_accessible :name, :description, :http_type, :http_method,
                  :period, :in_keys, :source, :header, :out_keys, :content_to_hash, :service

  validates :name, :presence => true,
                   :length => { :maximum => 200 }
  validates :http_type, :presence => true
  validates :http_method, :presence => true
  validates :source, :presence => true
  validates :out_keys, :presence => true

  validates :service, :presence => true

  serialize :in_keys, SymbolArrayJSONCoder.new
  serialize :header, JSONCoder.new({})
  serialize :out_keys, SymbolArrayJSONCoder.new

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
    ret = @runtime.eval content_to_hash
    ret.map { |d| d[:published] = Time.now unless d.include? :published }
    ret
  end

  private

  def init_env(user, params)
    @runtime = service.inner_runtime params || {}
    @user = user
    @runtime.add_params :meta => meta
  end

  def meta
    @meta ||= service.meta(@user)
    raise "Need register service(#{service.name}) first" unless @meta
    @meta.merge! :header => header
  end

  def uri
    @runtime.eval "\"#{source}\""
  end
end
