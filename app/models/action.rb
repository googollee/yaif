class Action < ActiveRecord::Base
  validates :name, :presence => true,
                   :length => { :maximum => 200 }
  validates :http_type, :presence => true
  validates :http_method, :presence => true
  validates :target, :presence => true

  validates :service, :presence => true

  belongs_to :service

  has_many :tasks

  def send_request(params)
    @get_body ||= eval "lambda { |params| #{self.body} }"
    RequestHelper.send "#{self.http_type}_request".to_sym, self.http_method.to_sym, self.target, @get_body.call(params)
  end

  def method_missing(m, *args, &block)
    return self.send(m, *args, &block) if self.respond_to?(m)
    self.service.send(m, *args, &block)
  end
end
