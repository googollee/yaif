class Task < ActiveRecord::Base
  attr_accessible :name, :user, :trigger, :trigger_params, :action, :action_params

  validates :name, :presence => true
  validates :user, :presence => true
  validates :trigger, :presence => true
  validates :action, :presence => true

  serialize :trigger_params, SymbolHashJSONCoder.new
  serialize :action_params, SymbolHashJSONCoder.new
  serialize :error_log, SymbolHashJSONCoder.new

  belongs_to :user
  belongs_to :trigger
  belongs_to :action

  def save
    self.last_run ||= Time.now
    super
  end

  def get_from_trigger
    trigger.get user, trigger_params
  end

  def filter_items(items)
    items_ordered = items.sort { |a, b| a[:published] <=> b[:published] }
    items_ordered.each do |i|
      yield i if item_published_after_last_run(i)
    end
  end

  def send_to_action(item)
    action.send_request user, get_params(item)
    self.run_count += 1
    self.last_run = item[:published]
  end

  def run
    self.error_log = {}
    items = get_from_trigger
    filter_items(items) { |i| send_to_action i }
  rescue Exception => e
    self.error_log = { :message => e.message, :backtrace => e.backtrace }
  ensure
    save
  end

  private

  def item_published_after_last_run(item)
    self.last_run ||= Time.now
    item[:published] ||= Time.now
    return item[:published] if item[:published] > last_run
    nil
  end

  def get_params(item)
    rt = RuntimeHelper::InnerRuntime.new
    rt.add_params item
    ret = action.in_keys.inject({}) { |o, k| o.merge! k => (rt.eval "\"#{action_params[k]}\"") }
    ret.merge :published => item[:published] || Time.now
  end
end
