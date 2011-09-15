class UsersController < ApplicationController
  
  before_filter :authenticate, :except => [:show, :new, :create]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user, :only => :destroy
  
  def show
    @user = User.find(params[:id])
    @title = @user.name
    @microposts = @user.microposts.paginate(:page => params[:page])
    if signed_in?
      @micropost = Micropost.new
    end   
  end
  
  def new
    if signed_in?
      redirect_to root_path
    else      
      @user = User.new
      @title = "Sign Up"      
    end    
  end
  
  def create
    
    # Temporary fix to allow json requests to always create a new user
    if signed_in? and ! request.format.json?
      redirect_to root_path      
    else
      @user = User.new(params[:user])
    
      if @user.save
        
        sign_in @user
        
        flash[:success] = "welcome to babble !"        
        respond_to do |format|
                 
          format.html {          
            redirect_to @user          
          }
        
          format.json { 
            render :json => {:action =>'create', :owner => @user }          
          }
          
        end
        
      else
        @user.password = ""
        @user.password_confirmation = ""
        @title = "Sign Up"
                
        respond_to do |format|

          format.html {
            render 'new'
          }

          format.json  {
            render :json => {:action =>'signup', 
              :error=> "sign up failed, please check your email to make sure it 
              hasn't already been used"}  
          }
        end
        
      end    
    end      
  end
  
  def edit
    @title = "Edit"    
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "profile updated !"
      redirect_to @user
    else
      @title = "Edit"
      render 'edit'
    end
  end
  
  def index
    @title = "Users"
    respond_to do |format|
      format.html { render :html => @users = User.paginate(:page => params[:page])}
      format.xml { render :xml => @users = User.all}
      format.json { render :json => { :items => User.all}}      
    end
    
  end
  
  def destroy
    user_to_be_deleted = User.find(params[:id])
    if current_user == user_to_be_deleted
      flash[:error] = "you cannot delete yourself via the web UI !"
    else
      user_to_be_deleted.destroy
      flash[:success] = "User deleted."  
    end    
    redirect_to users_path
  end
  
  def following
    show_follow(:following)
  end
  
  def followers
    show_follow(:followers)
  end
    
  private  
  
  def show_follow(action)
    @title = action.to_s.capitalize
    @user = User.find(params[:id])
    @users = @user.send(action).paginate(:page => params[:page])
    render 'show_follow'
  end
  
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end
    
  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end

end
