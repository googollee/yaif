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
