class ServicesController < ApplicationController
  respond_to :html, :js

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

  def auth
    @service = Service.find(params[:id])
    meta = @service.meta current_user
    if not meta
      @auth_url = @service.auth(session, auth_callback_service_url(@service))
    end
    render 'services/no_auth' if meta or (not @auth_url)
  end

  def auth_callback
    @service = Service.find(params[:id])
    @service.auth_meta(current_user, session)
  end
end
