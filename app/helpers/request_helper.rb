require 'net/http'
require 'net/https'

require 'oauth'
require 'twitter'

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
      {
        :site => meta[:site],
        :scheme => meta[:scheme],
        :signature_method => meta[:signature_method],
        :realm => root_url
      },
    )
    access_token = OAuth::AccessToken.new consumer, meta[:access_token], meta[:access_secret]
    get_body case method
      when :get, :delete, :head
        access_token.send method, path, meta[:header]
      else
        access_token.send method, path, body, meta[:header]
      end
  end

  def twitter_request(method, path, body, meta)
    client = Twitter::Client.new :consumer_key => meta[:key],
                                 :consumer_secret => meta[:secret],
                                 :oauth_token => meta[:access_token],
                                 :oauth_token_secret => meta[:access_secret]
    action = path.split('/')[2].split('.')[0]
    ret = case method
    when :get
      client.send(action)
    when :post
      client.send(action, body)
    else
      raise "Doesn't know how to #{method} to #{path}."
    end
    ret.to_json
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
