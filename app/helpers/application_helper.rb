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

class SymbolArrayJSONCoder < JSONCoder
  def load(s)
    super(s).map { |i| i.to_sym }
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
