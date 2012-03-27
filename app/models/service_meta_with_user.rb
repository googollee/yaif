class ServiceMetaWithUser < ActiveRecord::Base
  attr_accessible :user, :service, :data

  self.table_name = "service_meta_with_user"

  validates :user, :presence => true
  validates :service, :presence => true

  serialize :data, SymbolHashJSONCoder.new

  belongs_to :service
  belongs_to :user
end
