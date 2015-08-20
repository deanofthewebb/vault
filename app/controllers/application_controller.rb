class ApplicationController < ActionController::Base
  # rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
  #   render :text => exception, :status => 500
  # end
  helper_method :user_setup
  before_filter :authenticate

  def user_setup
    u_id = session[:user_id]

    if (!u_id.nil?)
      temp_user = User.where("login=?", "cb\\#{u_id}").first
      if(temp_user.nil?)
        @user = User.new(:login => "cb\\#{u_id}", :encrypted_password => "---")
        @user.save
        sign_in(@user)
      else
        sign_in temp_user
      end
    end
  end

  def authenticate
    Rails.logger.info "parameters for authentication: #{params}"
    if(session[:user_id].nil? && controller_name != 'login' && controller_name != 'saml' && controller_name != 'sessions' && action_name != 'view')
      Rails.logger.info("signing in...")
      login

    elsif (controller_name == 'sessions' && action_name == 'new')
      login
    elsif (action_name == 'destroy' && controller_name == 'sessions')
      Rails.logger.info("signing out...")
      logout
      #redirect_to "https://cb.okta.com/app/UserHome"
    else 
      Rails.logger.info("setting up the user login")
      user_setup
    end
  end

  def login
    session[:go_back_url] = request.url
    puts controller_name
    redirect_to(controller: '/saml')
  end

  def logout
    reset_session
    redirect_to saml_logout_url
  end
end
