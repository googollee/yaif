class TriggersController < ApplicationController
  respond_to :html, :js

  def index
    service = Service.find(params[:service_id])
    @triggers = service.triggers
    respond_with @triggers
  end
end
