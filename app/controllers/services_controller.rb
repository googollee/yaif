class ServicesController < ApplicationController
  http_basic_authenticate_with :name => Rails.configuration.basic_auth_username,
                               :password => Rails.configuration.basic_auth_password,
                               :only => [:show_callback]

  respond_to :html, :js
  respond_to :text, :only => [:show_callback]

  def index
  end

  def services_with_trigger
    @services = Service.where "id IN (SELECT service_id FROM triggers)"
    respond_with @services
  end

  def services_with_action
    @services = Service.where "id IN (SELECT service_id FROM actions)"
    respond_with @services
  end

  def show_callback
    @services = Service.all
  end

  def auth
    @service = Service.find(params[:id])
  end

  def redirect_to_auth_url
    service = Service.find(params[:id])
    auth_url = service.auth(session, auth_callback_service_url(service))
    redirect_to auth_url
  end

  def auth_callback
    @service = Service.find(params[:id])
    @service.auth_meta(current_user, session, params)
  end
end
