require "./lib/shared_modules"

class HomeController < ApplicationController    
  before_action :authenticate_user, :except => [:login, :validate_login, :forgot_password]

  include Generate_encrypt_password

  def index
  end

  def login         
      @user_id = params[:id]     
      @password = params[:token]

      if @user_id.nil?
        @user = User.new 
        render "login"	
      else
        @user = User.find_by(user_id: @user_id, password: @password, is_active: true)

        if @user
          @user.is_new_user = true  #to hide menu bar in change password screen
          #assigning session values
          session_values(@user)
          
          redirect_to home_change_password_path
        else
          @user = User.new                   
          render "login"
        end
      end
  end

  def validate_login   
    @email_address = params[:user][:email_address]
    @password = generate_encrypted_password(params[:user][:password]).chomp

    @user = User.find_by(email_address: @email_address, password: @password, is_active: true)
    
    if @user && !@user.is_new_user
      #assigning session values
      session_values(@user)
    
      redirect_to home_index_path
    else
      @user = User.new
      @user.email_address = @email_address
                     
      flash.now[:notice] = 'Invalid User Name or Password'        
      render "login"
    end
  end

  def forgot_password
    @email_address = params[:email_address]

    respond_to do |format|
        format.json { render json: @email_address.to_json }
    end
  end

  def change_password
    if request.post?
      @current_password = params[:user][:current_password]
      @new_password = generate_encrypted_password(params[:user][:new_password]).chomp
      @is_change_pwd_link = params[:user][:is_change_pwd_link]
      @message = ""

      if !@current_password.nil? && session[:current_password] != generate_encrypted_password(@current_password).chomp    
        @message = "Current Password is wrong"         
      elsif session[:current_password] == @new_password
        @message = "Current Password and New Password should not be same"                 
      end

      if @message == ""
        @user = User.find(session[:current_user_id])
        if @user.update(password: @new_password, is_new_user: false)
            #assigning session values
            session_values(@user)
            
            redirect_to home_index_path
        else
          @user = User.new
          @user.is_change_pwd_link = @is_change_pwd_link

          flash.now[:notice] = "Error Occured while updating New Password"       
          render "change_password"
        end
      else    
          @user = User.new
          @user.is_change_pwd_link = @is_change_pwd_link

          flash.now[:notice] = @message      
          render "change_password"
      end
    else      
      @user = User.new
      @user.is_change_pwd_link = params[:link]
      render "change_password"
    end  	
  end

  def logout
    session[:current_user_id] = nil
    session[:current_email_address] = nil
    session[:current_password] = nil
    session[:current_is_new_user] = nil

    redirect_to home_login_path
  end

  private
  def session_values(user)
      session[:current_user_id] = user.user_id
      session[:current_email_address] = user.email_address
      session[:current_password] = user.password
      session[:current_is_new_user] = user.is_new_user
  end

end
