class Task < ActiveRecord::Base
  validates :name, :presence => true
  validates :user, :presence => true
  validates :trigger, :presence => true
  validates :action, :presence => true

  serialize :trigger_params, Hash
  serialize :action_params, Hash

  belongs_to :user
  belongs_to :trigger
  belongs_to :action

  def run
    content = self.trigger.get self.user, self.trigger_params
    self.action.send_request self.user, ActiveSupport::JSON.decode(content)
    self.run_count += 1
    self.last_run = Time.now
    self.save
  end
end
