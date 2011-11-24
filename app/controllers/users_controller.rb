class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to Yet Another IFttt!"
      redirect_to @user
    else
      @user.password = @user.password_confirmation = ''
      render 'new'
    end
  end
end
