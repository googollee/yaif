class Service < ActiveRecord::Base
  validates :name, :presence => true,
                   :length => { :maximum => 200 }
  validates :icon, :presence => true
  validates :auth_type, :presence => true

  serialize :auth_data, Hash

  has_many :triggers
  has_many :actions

  def method_missing(m, *args, &block)
    instance_eval(self.helper) if self.respond_to?(:helper) and self.helper
    return self.send(m, *args, &block) if self.respond_to?(m)
    super
  end
end
