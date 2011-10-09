class SessionsController < ApplicationController
  
  def new
    respond_to do |format|
      format.html { @title = "Sign in" }
      format.json  { head :ok }
    end
  end
  
  def create_from_auth
        
    auth = request.env["omniauth.auth"]
    user = User.find_with_omniauth(auth) || User.create_with_omniauth(auth)
        
    sign_in user
    
    redirect_back_or root_path
    
  end
  
  def create
           
    user = User.authenticate(params[:session][:email],params[:session][:password])
    
    if user.nil?
      
      respond_to do |format|

        format.html {
          flash.now[:error] = "Invalid email or password, please try again or create a new account"
          @title = "Sign in"
          render 'new'
        }

        format.json  {
          render :json => {:action =>'login', :error=> 'invalid user or email'}  
        }
      end
      
    else
      #sign the user in and render the user's show (profile) page    
      sign_in user
      
      respond_to do |format|
        format.html { 
          redirect_back_or root_path
        }
        format.json  {
          render :json => { :action =>'login', :owner => current_user  }
        }
      end     
      
    end
    
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end

end
