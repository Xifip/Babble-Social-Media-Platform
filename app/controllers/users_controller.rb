class UsersController < ApplicationController
  
  def show
    @user = User.find(params[:id])
    @title = @user.name
  end
  
  def new
    @user = User.new
    @title = "Sign Up"
  end
  
  def create
    @user = User.new(params[:user])
    
    if @user.save
      flash[:success] = "welcome to babble !"
      redirect_to @user
    else
      @user.password = ""
      @user.password_confirmation = ""
      @title = "Sign Up"
      render 'new'
    end
    
  end

end