require 'oauth'
require 'oauth2'

module AuthHelper
  extend self

  RuntimeHelper.init_env(self)

  # noauth
  def noauth_auth(service, session, callback_url)
    nil
  end

  def noauth_get_meta(service, session, params)
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
  def oauth1_auth(service, session, callback_url)
    consumer_params = service.auth_data[:consumer_params].symbolize_keys
    consumer_params[:site] ||= consumer_params[:auth_site]
    consumer_params[:realm] ||= root_url

    consumer = OAuth::Consumer.new(
      service.auth_data[:key],
      service.auth_data[:secret],
      consumer_params
    )

    session[:request_token] = consumer.get_request_token
    session[:request_token].authorize_url :oauth_callback => callback_url
  end

  def oauth1_get_meta(service, session, params)
    access_token = session[:request_token].get_access_token :oauth_verifier => params[:oauth_verifier]
    {
      :key => service.auth_data[:key],
      :secret => service.auth_data[:secret],
      :access_token => access_token.token,
      :access_secret => access_token.secret,
      :consumer_params => consumer_params
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
  def oauth1a_auth(service, session, callback_url)
    consumer_params = service.auth_data[:consumer_params].symbolize_keys
    consumer_params[:site] ||= consumer_params[:auth_site]
    consumer_params[:realm] ||= root_url
    consumer = OAuth::Consumer.new(
      service.auth_data[:key],
      service.auth_data[:secret],
      consumer_params
    )

    session[:request_token] = consumer.get_request_token :oauth_callback => callback_url
    session[:request_token].authorize_url
  end

  def oauth1a_get_meta(service, session, params)
    oauth1_get_meta service, session, params # same as auth 1.0
  end

  def oauth2_auth(service, session, callback_url)
    client_params = service.auth_data[:client_params].symbolize_keys.merge :raise_errors => false
    client = OAuth2::Client.new(
      service.auth_data[:key],
      service.auth_data[:secret],
      client_params
    )

    session[:oauth2_callback] = callback_url

    if service.auth_data[:auth_params]
      client.auth_code.authorize_url service.auth_data[:auth_params].merge(:redirect_uri => callback_url)
    else
      client.auth_code.authorize_url :redirect_uri => callback_url
    end
  end

  def oauth2_get_meta(service, session, params)
    client_params = service.auth_data[:client_params].symbolize_keys
    client = OAuth2::Client.new(
      service.auth_data[:key],
      service.auth_data[:secret],
      client_params
    )

    token = client.auth_code.get_token(params[:code], :redirect_uri => session[:oauth2_callback])
    {
      :key => client.id,
      :secret => client.secret,
      :client_params => client.options.merge(:site => client.site),
      :token => token.token,
      :token_params => token.params
    }
  end
end
