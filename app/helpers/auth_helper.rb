require 'oauth'

module AuthHelper
  extend self

  # noauth
  def noauth_auth(service, session)
    nil
  end

  def noauth_get_meta(service, session)
    {}
  end

  # oauth 1.0 authentication
  #   key: oauth key
  #   secret: oauth secret
  #   site: url for authenticating and accessing
  #   auth_site: url for authenticating, if not exist, use :site
  #   access_site: url for accessing, if not exist, use :site
  #   request_token_source: path of request token
  #   access_token_source: path of access token
  #   authorize_source: path of authorize
  #   signature_method: signature method
  #   scheme: usually :header
  def oauth1_auth(service, session)
    consumer = OAuth::Consumer.new(
      service.auth_data[:key],
      service.auth_data[:secret],
      {
        :site => service.auth_data[:auth_site] || service.auth_data[:site],
        :request_token_path => service.auth_data[:request_token_source],
        :access_token_path => service.auth_data[:access_token_source],
        :authorize_path => service.auth_data[:authorize_source],
        :signature_method => service.auth_data[:signature_method],
        :scheme => service.auth_data[:scheme],
        :realm => root_url,
      }
    )

    session[:request_token] = consumer.get_request_token
    session[:request_token].authorize_url :oauth_callback => oauth_callback_url
  end

  def oauth1_get_meta(service, session)
    access_token = session[:request_token].get_access_token
    {
      :key => service.auth_data[:key],
      :secret => service.auth_data[:secret],
      :site => service.auth_data[:access_site] || service.auth_data[:site],
      :scheme => service.auth_data[:scheme],
      :signature_method => service.auth_data[:signature_method],
      :access_token => access_token.token,
      :access_secret => access_token.secret
    }
  end

  # oauth 1.0a authentication
  #   key: oauth key
  #   secret: oauth secret
  #   site: url for authenticating and accessing
  #   auth_site: url for authenticating, if not exist, use :site
  #   access_site: url for accessing, if not exist, use :site
  #   request_token_source: path of request token
  #   access_token_source: path of access token
  #   authorize_source: path of authorize
  #   signature_method: signature method
  #   scheme: usually :header
  def oauth1a_auth(service, session)
    consumer = OAuth::Consumer.new(
      service.auth_data[:key],
      service.auth_data[:secret],
      {
        :site => service.auth_data[:auth_site] || service.auth_data[:site],
        :request_token_path => service.auth_data[:request_token_source],
        :access_token_path => service.auth_data[:access_token_source],
        :authorize_path => service.auth_data[:authorize_source],
        :signature_method => service.auth_data[:signature_method],
        :scheme => service.auth_data[:scheme],
        :realm => root_url,
      }
    )

    session[:request_token] = consumer.get_request_token :oauth_callback => oauth_callback_url
    session[:request_token].authorize_url
  end

  def oauth1a_get_meta(service, session)
    oauth1_get_meta service, session # same as auth 1.0
  end

  private

  begin
    root_url
  rescue
    def root_url
      "http://root/url"
    end
  end

  begin
    oauth_callback_url
  rescue
    def oauth_callback_url
      "http://root/oauth_callback"
    end
  end
end
