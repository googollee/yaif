class UsersController < ApplicationController
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :not_sign_in, :only => [:new, :create]

  def new
    key = RegKey.get_validate_key params[:reg_key]
    puts "key = #{key}"
    if key
      @user = User.new :name => key.email.split("@")[0], :email => key.email
    else
      flash[:error] = "reg_key #{params[:reg_key]} is invalid."
      redirect_to root_path
    end
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

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes params[:user]
      flash[:success] = "Profile updated."
      redirect_to root_path
    else
      render 'edit'
    end
  end

  private

  def correct_user
    @user = User.find(params[:id])
    redirect_to root_path unless current_user? @user
  end

  def not_sign_in
    redirect_to root_path if signed_in?
  end
end
