require 'time'
require 'nokogiri'

module RuntimeHelper
  extend self

  class InnerRuntime
    def add_params(params)
      @params ||= {}
      @params.merge! params
    end

    def eval(str)
      instance_eval str
    end

    def method_missing(m, *args, &block)
      return self.send(m, *args, &block) if self.respond_to? m
      return @params[m] if @params and @params.include? m
      super
    end

    def xml(xml_str)
      Nokogiri::XML(xml_str)
    end

    def parse_xml(content, selector)
      (xml(content) / selector).inject([]) do |o, i|
        o << (yield i)
      end
    end

    def json(json_str)
      ActiveSupport::JSON.decode(json_str)
    end

    def parse_json(json_str, selector=nil)
      json(json_str).inject([]) do |o, i|
        o << (yield i)
      end
    end

    def grab_text(str, pattern)
      str.match(pattern)[1]
    rescue
      ''
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
