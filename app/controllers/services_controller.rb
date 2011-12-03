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
end
