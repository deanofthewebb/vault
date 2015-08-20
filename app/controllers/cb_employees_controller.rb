class CbEmployeesController < ApplicationController
before_filter :init
helper_method :filter_viewers
autocomplete :cb_employees, :network_name, :full => false

  def init
    if ((defined? @@employee_hash ) == nil || @@employee_hash.nil? || @@employee_hash.empty?)
      result = CbEmployeesHelper.query_pi_rest_service("http://pi.careerbuilder.com/services/TeamFoundation/CBEmployee")
      Rails.logger.info result.length
      cto = result.find{|e| e[:HHRepID] == 'epresley'}
      @@technology_employees = CbEmployeesHelper.subordinates(cto, result)
      @@employee_hash = CbEmployeesHelper.build_employee_hash(@@technology_employees)
      remove_missing_records
       @@employee_hash.each do |key, employee|
        unique_record = CbEmployees.where("full_name=? and network_name=?", employee[:full_name], employee[:network_name]).first
        if(unique_record.nil?)
          cb_employee = CbEmployees.create(full_name: employee[:full_name],
                           network_name: employee[:network_name],
                           employee_id: employee[:employee_id],
                           job_title: employee[:job_title],
                           is_manager: employee[:is_manager],
                           email: employee[:email],
                           manager: employee[:manager],
                           coworker: employee[:coworkers],
                           subordinates: employee[:subordinates],
                           additional_members: "")
          Rails.logger.info cb_employee.inspect

         else 
          unique_record.update(full_name: employee[:full_name],
                               network_name: employee[:network_name],
                               job_title: employee[:job_title],
                               is_manager: employee[:is_manager],
                               email: employee[:email],
                               manager: employee[:manager],
                               coworker: employee[:coworkers],
                               subordinates: employee[:subordinates])
        end
       end
     end
   end

  def home
    user_id = CbEmployeesHelper.get_current_user(current_user.login)
    coworkers_to_remove = Array.new
    sub_to_remove = Array.new
    @@current_employee_data = @@employee_hash["#{user_id}"].clone
    @@current_employee_data = CbEmployeesHelper.refresh_additional_employees(@@employee_hash, @@current_employee_data, current_user.login)
    Rails.logger.info ("current employee data: #{@@current_employee_data}")

    @current_cb_employee = CbEmployees.where("network_name=?", user_id)

    @current_cb_employee[0][:coworker].each do |coworker|
      cow_access = SecretLinks.where("username=? and added_users=?", current_user.login, coworker[:network_name]).first
      if(!cow_access.nil? && !cow_access[:blessed]) 
        coworkers_to_remove.push(coworker)
        Rails.logger.info "Removing coworker: #{@current_cb_employee[0][:coworker]}"
      end
    end

    @current_cb_employee[0][:subordinates].each do |sub|
      sub_access = SecretLinks.where("username=? and added_users=?", current_user.login, sub[:network_name]).first
      if(!sub_access.nil? && !sub_access[:blessed]) 
        sub_to_remove.push(sub)
      end
    end
    coworkers_to_remove.each do |f|
      @current_cb_employee[0][:coworker].delete(f)
    end

    sub_to_remove.each do |f|
      @current_cb_employee[0][:subordinates].delete(f)
    end

     respond_to do |format|
      format.html # home.html.erb
      # format.xml  { render :xml => @current_cb_employee }
     end
  end

  def remove_missing_records
    user_logged_in = CbEmployeesHelper.get_current_user(current_user.login)
    records_in_db = CbEmployees.all
    records_in_db.each do |record|
      record_name = record.network_name
      last_update_time = record[:updated_at].to_datetime
      if @@employee_hash["#{record_name}"] == nil
        if(last_update_time < (DateTime.now-60.days))
          CbEmployees.destroy(record)
        elsif (user_logged_in == record.manager[:network_name])
          puts "#{DateTime.now} - #{last_update_time}"
          timeframe = (60.days-(DateTime.now-last_update_time)).to_i / 1.day
          flash[:alert] = " user #{record_name} has been terminated, you have #{timeframe} days to reallocate his files!"
        end
      end
    end
  end

  def edit_access
  end

  def filter_viewers
    begin
      CbEmployeesHelper.filter(current_user.login, @@employee_hash, params)
      redirect_to root_url, notice: "Subscriber was succesfully added/removed!"
    rescue 
      redirect_to root_url, alert: "Subscriber was not successfully added/removed, make sure the username entered exists!"
    end
  end

  def reset_access
    user = get_current_user
    accesses = SecretLinks.where("username=?",current_user.login)
    accesses.each do |member|
      SecretLinks.destroy(member)
    end
    @@employee_hash = CbEmployeesHelper.build_employee_hash(@@technology_employees)
    @@current_employee_data = @@employee_hash["#{user}"].clone
    current_employee_subscribers = CbEmployees.where("full_name=? and network_name=?", full_username(current_user.login), user).first
    current_employee_subscribers.update(additional_members: "")
    Rails.logger.info "current_employee after reset: #{current_employee_subscribers}"
    redirect_to root_url
  end

  def self.full_username(current_user)
    current_cb_employee = CbEmployees.where("network_name=?", CbEmployeesHelper.get_current_user(current_user))
    username  = current_cb_employee.first.full_name
    return username
  end

  def reset
  end
end
