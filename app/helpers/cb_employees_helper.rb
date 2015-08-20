module CbEmployeesHelper

  def self.query_pi_rest_service(uri_string) 
    uri = URI(uri_string) 
    res = Net::HTTP.get_response(uri) 
    response_hash = JSON.parse(res.body) 
    if res.is_a?(Net::HTTPSuccess) 
      service_results = response_hash["Result"] 
      symbolized_hash = symbolize_hash_array(service_results) 
    else 
      Rails.logger.error("Response did NOT return as a success!") 
    end 
    return symbolized_hash
  end

  def self.get_current_user(current_user)
    return current_user.gsub("cb\\", "")
  end

  def self.symbolize_hash_array(hash_array) 
    hash_array.each do |f| 
      f.keys.each do |key| 
        f[(key.to_sym rescue key) || key] = f.delete(key) 
      end 
    end
  end

  def self.subordinates(worker_hash, response_hash)
    res = Array.new
    if(worker_hash[:IsAManager] == false)
    res.push(worker_hash) 
      return res
    else
      res.push(worker_hash)
      response_hash.each do |e|
        if e[:ReportToEmployeeID] == worker_hash[:EmployeeID]
          (subordinates(e, response_hash)).each do |f|
            res.push(f)
          end
        end
      end 
      return res
    end    
  end

  def self.build_employee_hash(response_hash)
    employee_hash = Hash.new
    response_hash.each do |element|
      employee = create_employee(element, response_hash)
      employee_hash.merge!("#{employee[:network_name]}" => employee)
    end
    return employee_hash
  end

  def self.refresh_additional_employees(employee_hash, current_employee_data, current_user)
    list_to_remove = Array.new
    list_to_add = Array.new
    list_to_add = SecretLinks.where("username=? and blessed=?", current_user, true).pluck(:added_users)
    current_employee_data[:additional_members] = Array.new
    list_to_add.each do |add|
      Rails.logger.info "adding"
      temp_to_add = employee_hash["#{add}"]
      current_employee_data[:additional_members].push(:network_name => temp_to_add[:network_name], :full_name => temp_to_add[:full_name], :job_title => temp_to_add[:job_title])
    end
    current_employee = CbEmployees.where("network_name=?", current_user.gsub("cb\\", "")).first
    Rails.logger.info current_employee.inspect
    current_employee.update(additional_members: current_employee_data[:additional_members])
    Rails.logger.info "current_employee = #{current_employee.inspect}"
  end

  def self.create_employee(cbemployee_hash, response_hash)
    employee = Hash.new
    employee[:employee_id] = cbemployee_hash[:EmployeeID]
    employee[:network_name] = cbemployee_hash[:HHRepID]
    employee[:full_name] = "#{cbemployee_hash[:FirstName]} #{cbemployee_hash[:LastName]}"
    employee[:email] = cbemployee_hash[:Email]
    employee[:job_title] = cbemployee_hash[:JobTitle]
    employee[:is_manager] = cbemployee_hash[:IsAManager]
    manager = response_hash.find{|e| e[:IsAManager] == true && e[:EmployeeID] == cbemployee_hash[:ReportToEmployeeID]}
    employee.merge!( :manager => { :network_name => "#{manager[:HHRepID]}", :full_name => "#{manager[:FirstName]} #{manager[:LastName]}", :job_title => manager[:JobTitle]}) unless manager.nil?
    coworkers = response_hash.find_all{|e| e[:ReportToEmployeeID] == cbemployee_hash[:ReportToEmployeeID] && "#{e[:FirstName]} #{e[:LastName]}" != employee[:full_name]}
    employee[:coworkers] = Array.new
    coworkers.each do |workers|
      employee[:coworkers].push(:network_name => workers[:HHRepID], :full_name => "#{workers[:FirstName]} #{workers[:LastName]}", :job_title => workers[:JobTitle])
    end
    employee[:subordinates] = Array.new
    subordinates(cbemployee_hash, response_hash).each do |element|
      employee[:subordinates].push(:network_name => "#{element[:HHRepID]}", :full_name => "#{element[:FirstName]} #{element[:LastName]}", :job_title => element[:JobTitle]) unless element.nil?
    end
    return employee
  end

    def self.accessible_files(current_user, current_employee_data)
    usernames_accessible = Array.new
    user_id = current_user.gsub("cb\\", "")
    list_to_remove = SecretLinks.where("added_users=? and blessed=?", user_id, false).pluck(:username)
    coworker = ""
    sub = ""
      manager = "cb\\#{current_employee_data[0]['manager'][:network_name]}"
      manager_access = SecretLinks.where("username=? and added_users=?", manager, user_id).pluck(:blessed)
      usernames_accessible.push(manager) unless !manager_access

    current_employee_data[0]['coworker'].each do |element|
      coworker = "cb\\#{element[:network_name]}"
      coworker_access = SecretLinks.where("username=? and added_users=?", coworker, user_id).pluck(:blessed)
      usernames_accessible.push(coworker) unless (usernames_accessible.include?(coworker) || list_to_remove.include?(coworker) || !coworker_access)
    end
    current_employee_data[0]['subordinates'].each do |element|
      sub = "cb\\#{element[:network_name]}"
      if (sub != user_id)
        usernames_accessible.push(sub) unless (usernames_accessible.include?(sub) || list_to_remove.include?(sub))
      end
    end

    #users that invited you to see their files
    list_to_add = SecretLinks.where("added_users=? and blessed=?", user_id, true).pluck(:username)
    list_to_add.each do |element|
      usernames_accessible.push(element) unless usernames_accessible.include?(element)
    end
    usernames_accessible.push("#{current_user}")
    Rails.logger.info("current usernames accessible: #{usernames_accessible}")
    return usernames_accessible.uniq
  end

   def self.recursive_access(user_to_add, employee_hash)
    list_of_users = Array.new
      temp_user_hash = employee_hash["#{user_to_add}"]
      temp_user_hash[:subordinates].each do |sub|
        list_of_users.push(sub[:network_name])
      end
    return list_of_users
  end

  def self.filter(current_user, employee_hash, params)
    if(employee_hash["#{params[:added_user]}"].nil?)

      raise "error"

    else
    blessed = false
    Rails.logger.info "new params -------------> #{params}"
    user_edit = params[:added_user]
    if(params[:add] == "remover")
      blessed = false
      if(params[:recursive] == "1")
        list_to_remove = CbEmployeesHelper.recursive_access(user_edit, employee_hash)
        list_to_remove.each do |e|
          link = SecretLinks.where("username=? and added_users=?", current_user, e).first
          if (!link.nil?)
            link.update(blessed: blessed) unless (user_edit == current_user.gsub("cb\\", ""))
          else
            SecretLinks.create(username: current_user, added_users: e, blessed: blessed) unless (user_edit == current_user.gsub("cb\\", ""))
          end
        end
      else
        Rails.logger.info "remove but not recursive"
        link = SecretLinks.where("username=? and added_users=?", current_user, user_edit).first
        if (!link.nil?)
          link.update(blessed: blessed) unless user_edit == current_user.gsub("cb\\", "")
        else
          SecretLinks.create(username: current_user, added_users: user_edit, blessed: blessed) unless (user_edit == current_user.gsub("cb\\", ""))
        end
      end

    elsif(params[:add] == "adder")
      blessed = true
      if(params[:recursive] == "1")
        Rails.logger.info "add and recursive"
        list_to_add = CbEmployeesHelper.recursive_access(user_edit, employee_hash)
        list_to_add.each do |e|
          link = SecretLinks.where("username=? and added_users=?", current_user, e).first
          if(link.nil?)
            SecretLinks.create(username: current_user, added_users: e, blessed: blessed)
          else
            link.update(blessed: blessed)
          end
        end
      else
        Rails.logger.info "add and not recursive"
        link = SecretLinks.where("username=? and added_users=?", current_user, user_edit).first
        if(link.nil?)
          SecretLinks.create(username: current_user, added_users: user_edit, blessed: blessed)
        else
          link.update(blessed: blessed)
        end
      end
    end
  end
  end
end
