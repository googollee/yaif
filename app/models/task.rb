class Task < ActiveRecord::Base
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
    items_order = items.sort { |a, b| a[:published] <=> b[:published] }
    items_order.each do |i|
      yield i unless last_run && i[:published] && (i[:published] <= last_run)
      @last_run = i[:published] unless @last_run && i[:published] && (i[:published] <= @last_run)
    end
  end

  def send_to_action(item)
    rt ||= RuntimeHelper::InnerRuntime.new
    rt.add_params item
    params = action.in_keys.inject({}) do |o, k|
      o.merge! k => (rt.eval "\"#{action_params[k]}\"")
    end
    action.send_request user, params
  end

  def run
    begin
      self.error_log = {}
      @last_run = last_run
      filter_items get_from_trigger do |i|
        send_to_action i
        self.run_count += 1
      end
    rescue Exception => e
      self.error_log = { :message => e.message, :backtrace => e.backtrace }
    end
    self.last_run = @last_run || Time.now
    save
  end
end
