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

  def init_env(obj)
    begin
      root_url
      obj.root_url
    rescue
      def obj.root_url
        "http://root/url"
      end
    end

    begin
      oauth_callback_url
      obj.oauth_callback_url
    rescue
      def obj.oauth_callback_url
        "http://root/oauth_callback"
      end
    end
  end
end
