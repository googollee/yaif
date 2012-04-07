require 'net/http'
require 'net/https'

require 'oauth'
require 'oauth2'

module RequestHelper
  extend self

  RuntimeHelper.init_env(self)

  def direct_request(method, uri, body, meta={})
    uri = get_uri uri
    req = get_method(method).new uri.request_uri
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

  def oauth2_request(method, path, body, meta)
    client_params = meta[:client_params].symbolize_keys.merge :raise_errors => false
    client_params[:token_method] = client_params[:token_method].to_sym
    token_params = meta[:token_params].symbolize_keys

    client = OAuth2::Client.new meta[:key], meta[:secret], client_params
    token = OAuth2::AccessToken.new client, meta[:token], token_params.clone

    token = token.refresh! if token_params[:refresh_token]

    resp = token.send method, path, :body => body, :headers => meta[:header]

    raise resp.body unless resp.status.to_s =~ /^2\d\d$/
    resp.body
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
