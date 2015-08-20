require 'onelogin/ruby-saml/settings.rb'
require 'onelogin/ruby-saml/authrequest.rb'
require 'onelogin/ruby-saml/logoutrequest.rb'
require 'onelogin/ruby-saml/response.rb'
require 'onelogin/ruby-saml/logoutresponse.rb'
require 'onelogin/ruby-saml/validation_error.rb'

class SamlController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:consume]

  def index
    # insert identity provider discovery logic here
    settings = Account.get_saml_settings
    request = Onelogin::Saml::Authrequest.new
    redirect_to(request.create(settings))
  end

  def consume
    response = Onelogin::Saml::Response.new(params[:SAMLResponse])
    response.settings = Account.get_saml_settings

    logger.info "NAMEID: #{response.name_id}"
    puts response.is_valid?
    if response.is_valid?
      session[:user_id] = response.name_id
      Rails.logger.info "Session[:user_id: -- #{session[:user_id]}"
      Rails.logger.info "Session[:return_from_saml_url] -- #{session[:return_from_saml_url]}"
      if session[:return_from_saml_url].nil?
        flash[:notice]="You have successfully logged in"
        return redirect_to root_url
      end
      flash[:notice]="You have successfully logged in"
      redirect_to session[:return_from_saml_url]
    else
      redirect_to :action => :fail
    end
  end


  def show

  end

  def complete

  end

  def fail
  end


  def logout
    Rails.logger.info "in logout now....saml controller"
    if params[:SAMLRequest]
      return idp_logout_request

    elsif params[:SAMLResponse]
      return logout_response
    elsif params[:slo]
      return sp_logout_request
    else
      delete_session
    end
    flash[:notice]="You have successfully logged out"
  end

  def sp_logout_request
    settings = Account.get_saml_settings

    if settings.idp_slo_target_url.nil?
      logger.info "SLO IdP Endpoint not found in settings, executing then a normal logout'"
      delete_session
    else
      logout_request = OneLogin::RubySaml::Logoutrequest.new()
      session[:transaction_id] = logout_request.uuid
      logger.info "New SP SLO for userid '#{session[:userid]}' transactionid '#{session[:transaction_id]}'"

      if settings.name_identifier_value.nil?
        settings.name_identifier_value = session[:userid]
      end

      relayState =  url_for controller: 'saml', action: 'index'
      redirect_to logout_request.create(settings, :RelayState => relayState)
    end
  end



  def logout_response
    settings = Account.get_saml_settings

    if session.has_key? :transation_id
      logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings, :matches_request_id => session[:transation_id])
    else 
      logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings)
    end

    logger.info "LogoutResponse is: #{logout_response.to_s}"
    if not logout_response.validate
      logger.error "The SAML Logout Response is invalid"
    else
      if logout_response.success?
        logger.info "Delete session for '#{session[:userid]}'"
        delete_session
      end
    end
  end

  def idp_logout_request

    render :inline => "IdP initiated Logout not supported"
  end

  def delete_session
    session[:userid] = nil
    session[:attributes] = nil
    reset_session
  end
end
