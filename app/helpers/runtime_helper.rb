module RuntimeHelper
  extend self

  class InnerRuntime
    def initialize(def_string, params)
      @params = params
      instance_eval def_string
    end

    def eval(str)
      instance_eval str
    end

    def method_missing(m, *args, &block)
      return self.send(m, *args, &block) if self.respond_to? m
      return @params[m] if @params and @params.include? m
      super
    end
  end
end
