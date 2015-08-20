require 'json'
require 'net/http'

module SecretFilesHelper
  def self.create_json(file_contents, databag_item_info)
    binary_representation = file_contents.read.unpack('h*')
    path = "public/data/"
    make_dir(path.split("/"))
    file_name = databag_item_info[0][:environment] + "_" + databag_item_info[0][:role] + "_" + databag_item_info[0][:file_name]
    name = File.join(path, file_name)
    name << ".json"
    File.open(name, 'wb') do |f|
      f.puts("{")
      f.puts("  \"id\":\"" << file_name<< "\",")
      f.puts("  \"file_name\":\"" << databag_item_info[0][:file_name]<< "\",")
      f.puts("  \"data\":" << binary_representation.to_s)
      f.puts("}")
    end
    return name
  end
 

  def self.knife_upload(path, secret_key)
    command = "knife data bag from file secrets \"" << path << "\" --secret " << secret_key 
    raise "There was an error uploading the Data Bag Item with command: #{command}" unless system command
    File.delete(path)
  end
  
  def self.knife_delete(secret_file)
    databag_item = secret_file[:environment] + '_' + secret_file[:role] + '_' + secret_file[:file_name]
    command = "knife data bag delete secrets \"" << databag_item << "\" -y"
    raise "There was an error deleting the Data Bag Item with command: #{command}" unless system command
  end

  def self.as_array(input_array)
    array_to_return = []
    if(input_array.class == Array)
      array_to_return = input_array
    else
      array_to_return << input_array
    end
    return array_to_return
  end

  def self.make_dir(token)
    1.upto(token.size) do |n|
      dir = token[0..n]
      Dir.mkdir(dir.join('/')) unless (dir.nil? || Dir.exist?(dir.join('/'))) 
    end
  end

  def self.collect_secret_from_backup(secret_file)
    dirname = "public/data/"
    make_dir(dirname.split("/"))
    time = (!secret_file[:updated_at].blank? && secret_file[:updated_at].to_time) || secret_file[:created_at].to_time
    timestamp = time.strftime('%H%M')
    user = secret_file[:login].gsub('\\', '_')
    formatted_file = "#{secret_file[:environment]}_#{secret_file[:role]}_#{user}_#{secret_file[:file_name].split(".")[0]}_#{timestamp}#{File.extname(secret_file[:file_name])}"
      get_servers.each do |server|
        if (!File.exist?(Rails.root.join("#{dirname}#{formatted_file}")))
          command = "wget -O #{dirname}/#{formatted_file} --user admin --password password http://#{server}.atl.careerbuilder.com/artifactory/PI_Vault/#{time.month}_#{time.year}/#{time.day}/#{formatted_file}"
          system command
        end
      end

      if (!File.exist?(Rails.root.join("#{dirname}#{formatted_file}")))
        raise "The file #{formatted_file} could not be found on any of the backup servers!"
      end
    end

  def self.decrypt_and_store_secret(secret_file)
    collect_secret_from_backup(secret_file)
  rescue Exception => e
    Rails.logger.info "Exception thrown: #{e}"
    raise e
  end

  def self.backup_secret (updated_time, original_file_name, file_name_path, environment, role, user)
    Rails.logger.info "updated_time: #{updated_time}, original_file_name: #{original_file_name}, file_name_path: #{file_name_path}, environment: #{environment}, role: #{role}"
    time = Time.new
    month_year = "#{time.month}_#{time.year}"
    day = time.day
    timestamp = updated_time.strftime('%H%M')
    user = user.gsub(/\\/,"_")
    file_uploaded = "#{File.basename("#{environment}_#{role}_#{user}_#{original_file_name}", ".*")}_#{timestamp}#{File.extname("#{original_file_name}")}"
    if (Rails.env != "test" && Rails.env != "development")  
      get_servers.each do |server|
        command = "curl --user admin:password --upload-file #{file_name_path} \"http://#{server}.atl.careerbuilder.com/artifactory/PI_Vault/#{month_year}/#{day}/#{file_uploaded}\""
        raise "There was an error uploading the Data Bag Item to artifactory with command: #{command}" unless system command
      end
    else
      command = "curl --user admin:password --upload-file #{file_name_path} \"http://ghqpichefnode6.atl.careerbuilder.com/artifactory/PI_Vault/#{month_year}/#{day}/#{file_uploaded}\""
      raise "There was an error uploading the Data Bag Item to artifactory with command: #{command}" unless system command
    end
  end

  def self.get_servers
    servers = Array["ghqpichefnode6", "ghqpiartifact02", "ghqpiartifact03"]
    return servers
  end

  def self.validate_user (username, secret_file)
    current_employee_data = CbEmployees.where("network_name=?", username.gsub("cb\\", ""))
    array_accessible = CbEmployeesHelper.accessible_files("#{username}", current_employee_data)
    @admin_users = Array[ "cb\\asom", "cb\\wboatin", "cb\\dewe", "cb\\elatimer", "cb\\cyoon"]
    validate_boolean = false
    if secret_file == ""
      validate_boolean = (@admin_users.include?("#{username}")) 
    else
      validate_boolean = (@admin_users.include?("#{username}") || (array_accessible.include?(secret_file[:login]) && array_accessible.include?(username)))
    end
    return validate_boolean
  end

  def self.new_and_edit_file(params, secret_key, user, delete)
    parameters = params[:secret_file]
    file = parameters[:attachment].open
    file_name = parameters[:attachment].original_filename
    secret_file_edit = nil
    if delete == true
      secret_file_edit = SecretFile.find(params[:id])
      user = secret_file_edit[:login]
    end
    new_upload = [{:file_name => file_name, :environment => parameters[:environment], :role => parameters[:role], :secret_key => secret_key, :login => "cb\\#{params[:owner][0]}"}]
    databag_item_json = SecretFilesHelper.create_json(parameters[:attachment], new_upload)
    if secret_file_edit != nil
      SecretFilesHelper.knife_delete(secret_file_edit)
      secret_file_edit.destroy
    end
      SecretFilesHelper.knife_upload(databag_item_json, secret_key)

    result = SecretFile.create(new_upload)
    timeTemp = (!result[0][:updated_at].blank? && result[0][:updated_at].to_time) || result[0][:created_at].to_time
    backup_secret(Time.parse(timeTemp.to_s), file_name, parameters[:attachment].path, parameters[:environment], parameters[:role], "cb\\#{params[:owner][0]}")
    return result
  end


  def self.edit_file(params, secret_file, secret_key, user)
    parameters = params[:secret_file]
    time = (!secret_file[:updated_at].blank? && secret_file[:updated_at].to_time) || secret_file[:created_at].to_time
    timestamp = time.strftime('%H%M')
    user = user.gsub('\\','_')
    formatted_file = "#{secret_file[:environment]}_#{secret_file[:role]}_#{user}_#{secret_file[:file_name].split(".")[0]}_#{timestamp}#{File.extname(secret_file[:file_name])}"
    user = user.gsub("_", "\\")
    file = File.new("public/data/#{formatted_file}")
    file_name = secret_file[:file_name]
    new_upload = [{:file_name => file_name, :environment => parameters[:environment], :role => parameters[:role], :secret_key => secret_key, :login => "cb\\#{params[:owner][0]}"}]
    databag_item_json = SecretFilesHelper.create_json(file, new_upload)
    SecretFilesHelper.knife_delete(secret_file)
    SecretFilesHelper.knife_upload(databag_item_json, secret_file[:secret_key])
    SecretFile.update(secret_file[:id], :file_name => file_name, :environment => parameters[:environment], :role => parameters[:role], :login => "cb\\#{params[:owner][0]}")
    updated_file = SecretFile.find(secret_file[:id])
    backup_secret(updated_file[:updated_at].to_time, File.basename(file_name), file.to_path, parameters[:environment], parameters[:role], "cb\\#{params[:owner][0]}")
    File.delete(file)
    return updated_file
  end
end

