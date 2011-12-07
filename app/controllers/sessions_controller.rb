class SessionsController < ApplicationController
  def root
    @tasks = current_user.tasks
  end

  def new
  end

  def create
    user = User.find_by_email(params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_to root_path
    else
      flash.now[:error] = "Invalid email/password combination."
      render "new"
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
