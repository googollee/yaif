module AuthHelper
  # oauth authentication
  #   key: oauth key
  #   secret: oauth secret
  #   site: url for authenticating and accessing
  #   auth_site: url for authenticating, if not exist, use :site
  #   request_token_source: path of request token
  #   access_token_source: path of access token
  #   authorize_source: path of authorize
  #   signature_method: signature method
  #   scheme: usually :header
  def oauth_site_different_auth(service)
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
        :realm => "",
      }
    )

    request_token = consumer.get_request_token
    request_token.authorize_url
  end
end
