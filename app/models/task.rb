class Task < ActiveRecord::Base
  validates :name, :presence => true
  validates :user, :presence => true
  validates :trigger, :presence => true
  validates :action, :presence => true

  belongs_to :user
  belongs_to :trigger
  belongs_to :action
end
