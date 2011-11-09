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

  def get_from_trigger
    trigger.get user, trigger_params
  end

  def filter_items(items)
    items.each do |i|
      yield i unless last_run && (i[:published] <= last_run)
      @last_run = i[:published] unless @last_run && (i[:published] <= @last_run)
    end
  end

  def send_to_action(item)
    action.send_request user, item
  end

  def run
    @last_run = last_run
    filter_items get_from_trigger do |i|
      send_to_action i
    end
    self.run_count += 1
    self.last_run = @last_run || Tiime.now
    save
  end
end
