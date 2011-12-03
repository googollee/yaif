class ActionsController < ApplicationController
  respond_to :html, :js

  def index
    service = Service.find(params[:service_id])
    @actions = service.actions
    respond_with @actions
  end
end
