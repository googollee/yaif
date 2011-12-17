class TriggersController < ApplicationController
  respond_to :html, :js

  def index
    @service = Service.find(params[:service_id])
    unless @service.meta(current_user)
      auth_url = @service.auth session, auth_callback_service_url(@service)
      if auth_url
        render 'triggers/service_auth'
        return
      end
      @service.auth_meta current_user, session
    end

    @triggers = @service.triggers
    respond_with @triggers
  end

  def show_crontab
    @periods = Trigger.all.inject({}) do |o, t|
      period = t.period
      o[period] = 1 unless o.include? period
      o
    end.keys
    puts @periods
    respond_with @periods
  end

  def trigger
    tasks = Task.where "trigger_id IN (SELECT id FROM triggers WHERE period='#{params[:period]}')"
    tasks.each { |t| t.run }
  end
end
