class Trigger < ActiveRecord::Base
  validates :name, :presence => true,
                   :length => { :maximum => 200 }
  validates :http_type, :presence => true
  validates :http_method, :presence => true
  validates :source, :presence => true
  validates :out_keys, :presence => true

  validates :service, :presence => true

  belongs_to :service

  has_many :tasks

  def get_atom
    content = RequestHelper.send("#{self.http_type}_request".to_sym, self.http_method.to_sym, self.source, nil)
    @convert_to_hash ||= eval "lambda { |content| #{self.content_to_hash} }"
    @convert_to_hash.call(content)
  end

  def method_missing(m, *arg, &block)
    return self.send(m, *arg, &block) if self.respond_to?(m)
    self.service.send(m, *arg, &block)
  end
end
