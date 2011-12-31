require 'net/http'
require 'net/https'

require 'oauth'

module RequestHelper
  extend self

  RuntimeHelper.init_env(self)

  def direct_request(method, uri, body, meta={})
    uri = get_uri uri
    req = get_method(method).new uri.path
    req.set_body_internal body
    res = Net::HTTP.start uri.host, uri.port, :use_ssl => (uri.scheme == "https") do |http|
      http.request req
    end
    get_body res
  end

  def oauth_request(method, path, body, meta)
    consumer = OAuth::Consumer.new(
      meta[:key],
      meta[:secret],
      meta[:consumer_params]
    )
    access_token = OAuth::AccessToken.new consumer, meta[:access_token], meta[:access_secret]
    get_body case method
      when :get, :delete, :head
        access_token.send method, path, meta[:header]
      else
        access_token.send method, path, body, meta[:header]
      end
  end

  private

  def get_uri(uri)
    uri += '/' if uri =~ /^[^:]*(:\/\/)*[^\/]*$/i
    uri = URI(uri)
  end

  def get_method(method)
    case method
    when /^get$/i
      Net::HTTP::Get
    when /^post$/i
      Net::HTTP::Post
    when /^put$/i
      Net::HTTP::Put
    when /^delete$/i
      Net::HTTP::Delete
    else
      raise "Unknown method: #{method}"
    end
  end

  def get_body(response)
    raise response.message unless response.code =~ /^2\d\d$/
    response.body
  end
end
