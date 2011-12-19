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
      render 'new'
    end
  end

  def show
    @task = Task.find params[:id]
  end

  def edit
    @task = Task.find params[:id]
  end

  def update
    puts params[:task]
    @task = Task.find params[:id]
    if @task.update_attributes(params[:task])
      flash[:success] = "Task updated."
      redirect_to @task
    else
      render 'edit'
    end
  end

  def destroy
    @task = Task.find params[:id]
    @task.delete
    flash[:success] = "Task [#{@task.name}] was deleted."
    redirect_to root_path
  end

  private

  def must_signed
    redirect_to root_path unless signed_in?
  end
end
