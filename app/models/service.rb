class Service < ActiveRecord::Base
  attr_accessible :name, :description, :auth_uri, :auth_type

  validates :name, :presence => true,
                   :length => { :maximum => 200 }
  validates :auth_uri, :presence => true
  validates :auth_type, :presence => true

  serialize :auth_data
end
