class SessionsController < ApplicationController
  
  def new
    @title = "Sign in"
  end
  
  def create
    
    user = User.authenticate(params[:session][:email],params[:session][:password])
    
    if user.nil?
      #render the sign in form with error message
      flash.now[:error] = "Invalid email or password, please try again or create a new account"
      @title = "Sign in"
      render 'new'      
    else
      #sign the user in and render the user's show (profile) page    
      sign_in user
      redirect_back_or root_path
    end
    
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end

end
