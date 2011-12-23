class SessionsController < ApplicationController
  before_filter :check_ssl, :only => [:new, :create]

  def root
  end

  def new
  end

  def create
    user = User.find_by_email(params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_to root_url(:protocol => 'http')
    else
      flash.now[:error] = "Invalid email/password combination."
      render "new"
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

  private

  def check_ssl
    redirect_to signin_url(:protocol => 'https') unless request.protocol =~ /^https:/
  end
end
