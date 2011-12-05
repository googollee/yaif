class TriggersController < ApplicationController
  respond_to :html, :js

  def index
    @service = Service.find(params[:service_id])
    if @service.meta(current_user)
      @triggers = @service.triggers
      respond_with @triggers
    else
      render 'triggers/service_auth'
    end
  end
end
