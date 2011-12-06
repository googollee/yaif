class TasksController < ApplicationController
  before_filter :must_signed

  def new
    @task = Task.new
  end

  def create
    @task = Task.new params[:task]
    @task.user = current_user
    if @task.save
      puts 'success'
      redirect_to @task
    else
      puts 'failed'
      render 'edit'
    end
  end

  def show
    @task = Task.find params[:id]
  end

  private

  def must_signed
    redirect_to root_path unless signed_in?
  end
end
