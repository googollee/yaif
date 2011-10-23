class Trigger < ActiveRecord::Base
  validates :name, :presence => true,
                   :length => { :maximum => 200 }
  validates :uri, :presence => true
  validates :service, :presence => true
  validates :do, :presence => true

  belongs_to :service
end
