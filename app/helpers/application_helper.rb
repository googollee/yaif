module ApplicationHelper
end

class JSONCoder
  def initialize(default = [])
    @default = default
  end

  def load(s)
    ActiveSupport::JSON.decode(s) rescue @default
  end

  def dump(o)
    o ||= @default
    o.to_json
  end
end

class SymbolHashJSONCoder < JSONCoder
  def initialize
    super({})
  end

  def load(s)
    super(s).symbolize_keys
  end
end
