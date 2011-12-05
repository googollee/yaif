class ActionsController < ApplicationController
  respond_to :html, :js

  def index
    @service = Service.find(params[:service_id])
    if @service.meta(current_user)
      @actions = @service.actions
      respond_with @actions
    else
      render 'actions/service_auth'
    end
  end
end
