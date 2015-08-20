class SecretFilesController < ApplicationController
  helper_method :set_params_delete_var_false
  helper_method :home_view
  helper_method :full_username
  helper_method :get_technology_hash
  rescue_from ActiveRecord::RecordNotUnique, with: :not_unique
  skip_before_filter :authenticate_user!, :only => [:view]
  before_filter :init, :except => [:index, :view, :show, :help, :about, :new, :edit, :create, :destroy]

  include SecretFilesHelper
  # GET /secret_files
  # GET /secret_files.xml

  def index
    @secret_files = ""
    @@array_to_check = accessible_files
    Rails.logger.info("#{@@array_to_check}")
    if SecretFilesHelper.validate_user(current_user.login, "", @@array_to_check)
      @secret_files = SecretFile.all
      Rails.logger.info "#{current_user.login} signed in at #{Time.now}"
    else

      @secret_files = SecretFile.where({ login: @@array_to_check})
    end

    respond_to do |format|
    format.html # index.html.erb
    format.xml  { render :xml => @secret_files }
    end
  end
  
  # GET /view
  def view
    @secret_files = SecretFile.all
    respond_to do |format|
      format.json {render :json => @secret_files}
    end
  end

  # GET /secret_files/1
  # GET /secret_files/1.xml
  def show
    @secret_file = SecretFile.find(params[:id])
    time = (!@secret_file[:updated_at].blank? && @secret_file[:updated_at].to_time) || @secret_file[:created_at].to_time
    timestamp = time.strftime('%H%M')
    user = @secret_file[:login].gsub('\\', '_')
    formatted_file = "#{@secret_file[:environment]}_#{@secret_file[:role]}_#{user}_#{@secret_file[:file_name].split(".")[0]}_#{timestamp}#{File.extname(@secret_file[:file_name])}"
    raise "non authorized user, #{current_user.login} not admin nor not equal to #{@secret_file.login}" unless SecretFilesHelper.validate_user(current_user.login, @secret_file, @@array_to_check)
    respond_to do |format|
      format.html       # show.html.erb
      format.xml  { render :xml => @secret_file }
    end
    send_file "public/data/#{formatted_file}"#, :filename => "#{@secret_file[:file_name]}"
  end

  def home
  end

  def help
  end

  def about
  end

  def recursive_access(user_to_add)
    list_of_users = Array.new
      temp_user_hash = @@employee_hash["#{user_to_add}"]
      temp_user_hash[:subordinates].each do |sub|
        list_of_users.push(sub[:network_name])
      end
    return list_of_users
  end
  #TODO change the Rails.logger.info to rails.logger.info also break up the if into private methods
  # move the methods that aren't that related to this controller to a different helper file
  def filter_viewers
    blessed = false
    Rails.logger.info params
    if(params[:add] == "remover")
      blessed = false
      if(params[:recursive] == "1")
        user_removed = params[:added_user].gsub("cb\\", "")
        list_to_remove = recursive_access(user_removed)
        list_to_remove.each do |e|
          link = SecretLinks.where("username=? and added_users=?", current_user.login, e).first
          if (!link.nil?)
            link.update(blessed: blessed)
          else
            SecretLinks.create(username: current_user.login, added_users: e, blessed: blessed)
          end
        end
      else
        Rails.logger.info "remove but not recursive"
        added_user = params[:added_user].gsub("cb\\", "")
        link = SecretLinks.where("username=? and added_users=?", current_user.login, added_user).first
        if (!link.nil?)
          link.update(blessed: blessed)
        else
          SecretLinks.create(username: current_user.login, added_users: added_user, blessed: blessed)
        end
      end

    elsif(params[:add] == "adder")
      blessed = true
      if(params[:recursive] == "1")
        Rails.logger.info "add and recursive"
        user_added = params[:added_user].gsub("cb\\", "")
        list_to_add = recursive_access(user_added)
        list_to_add.each do |e|
          link = SecretLinks.where("username=? and added_users=?", current_user.login, e).first
          if(link.nil?)
            SecretLinks.create(username: current_user.login, added_users: e, blessed: blessed)
          else
            link.update(blessed: blessed)
          end
        end
      else
        Rails.logger.info "add and not recursive"
        added_user = params[:added_user].gsub("cb\\", "")
        link = SecretLinks.where("username=? and added_users=?", current_user.login, added_user).first
        if(link.nil?)
          SecretLinks.create(username: current_user.login, added_users: added_user, blessed: blessed)
        else
          link.update(blessed: blessed)
        end
      end
    end
    redirect_to home_url
  end
  # GET /secret_files/new
  # GET /secret_files/new.xml
  def new
    Rails.logger.info(request.fullpath)
    @secret_file = SecretFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @secret_file }
    end
  end

  # GET /secret_files/1/edit
  def edit
    Rails.logger.info(request.fullpath)
    @secret_file = SecretFile.find(params[:id])
    raise "non authorized user, #{current_user.login} not admin nor not equal to #{@secret_file.login}" unless SecretFilesHelper.validate_user(current_user.login, @secret_file, @@array_to_check)
    SecretFilesHelper.decrypt_and_store_secret(@secret_file)
 end

  # POST /secret_files
  # POST /secret_files.xml
  def create
    begin
      existing_filenames = SecretFile.where('file_name=?', params[:secret_file][:attachment].original_filename)
      default_filenames = SecretFile.where('file_name=? and environment=?', params[:secret_file][:attachment].original_filename, "_default" )
      if((params[:secret_file][:environment] == "_default" && !existing_filenames.to_a.empty?) || (params[:secret_file][:environment] != "_default" && !default_filenames.to_a.empty?))
        users = ""
        existing_filenames.each do |user|
          users << " #{user.login}"
        end

        respond_to do |format|
          format.html {redirect_to(new_secret_file_path(:error_duplicate_filename=>"true", :user => "#{users}"))}
        end
      else
        @secret_file = file_upload(params)
      end
    rescue Exception => e
      if(e.is_a? ActiveRecord::RecordNotUnique)
        existing_filenames = SecretFile.where('file_name=? and environment=? and role=?', params[:secret_file][:attachment].original_filename, params[:secret_file][:environment], params[:secret_file][:role])
        users = ""
        existing_filenames.each do |user|
          users << " #{user.login}"
        end
        redirect_to(new_secret_file_path(:error_duplicate_info=>"true", :user=>"#{users}"))
      else
        redirect_to(new_secret_file_path(:error_nil_file=>"true"))
    end
    end
  end

  # PUT /secret_files/1
  # PUT /secret_files/1.xml
  def update
    @secret_file = file_upload(params)
  end

  # DELETE /secret_files/1
  # DELETE /secret_files/1.xml
  def destroy
    @secret_file = SecretFile.find(params[:id])
    raise "non authorized user, #{current_user.login} not admin nor not equal to #{@secret_file.login}" unless SecretFilesHelper.validate_user(current_user.login, @secret_file, @@array_to_check)
    Rails.logger.info "#{current_user.login} has deleted file #{@secret_file.file_name}"
    SecretFilesHelper.knife_delete(@secret_file)
    @secret_file.destroy
    respond_to do |format|
      format.html { redirect_to(secret_files_url) }
      format.xml  { head :ok }
    end
  end

  def file_upload(params)
    @tempfilename = ""
    existingsecret = ""
    begin
      if(params[:secret_file][:environment] == "" || params[:secret_file][:role] == "")
        raise ArgumentError
      end
      parameters = params[:secret_file]
      secret_key = SecureRandom.base64
      if(!parameters[:edit_form] || (!session[:delete_tag].nil? && session[:delete_tag]))
        @tempfilename = parameters[:attachment].original_filename

        if((!parameters[:edit_form]) && (params[:secret_file][:environment] == "_default" && !SecretFile.where("file_name=?", @tempfilename).to_a.empty?))
          raise ActiveRecord::RecordNotUnique, 'already existing record'
        elsif (params[:secret_file][:environment] == "_default" && !SecretFile.where("file_name=? and id!=?", @tempfilename, params[:id]).to_a.empty?)
          raise ActiveRecord::RecordNotUnique, 'already existing record'
        end

        new_upload = SecretFilesHelper.new_and_edit_file(params, secret_key, current_user.login.gsub("_","\\"), session[:delete_tag])
      else
        @secret_file = SecretFile.find(params[:id])
        @tempfilename = @secret_file[:file_name]

        if(params[:secret_file][:environment] == "_default" && !SecretFile.where("file_name=? and id!=?", @tempfilename, params[:id]).to_a.empty?)
          raise ActiveRecord::RecordNotUnique, 'already existing record'
        end
        SecretFilesHelper.edit_file(params, @secret_file, secret_key, @secret_file[:login])
      end

      respond_to do |format|
        format.html { redirect_to(index_url) }
        format.xml  { head :ok }
      end
    rescue Exception => e
      users = ""
      if(e.is_a? ActiveRecord::RecordNotUnique)
        existingsecret = SecretFile.where('file_name=?', "#{@tempfilename}")
        existingsecret.each do |user|
          users << "#{user.login}"
        end

        redirect_to(new_secret_file_path(:error_duplicate_info=>"true", :user=>"#{users}"))
      elsif(e.is_a? ArgumentError)
        redirect_to(new_secret_file_path(:error_empty_fields=>"true"))
      elsif(@secret_file.nil? && parameters[:edit_form])
        redirect_to(new_secret_file_path(:error_nil_file=>"true"))
      else
        redirect_to(new_secret_file_path(:error_generic=>"true"))
      end
    end
  end

  def set_params_delete_var_true
    session[:delete_tag]= true
  end

  def set_params_delete_var_false
    session[:delete_tag]= false
  end

  def delete_files
    Rails.logger.info ("File Delete #{params[:file_name]}")
    File.delete("public/data/#{params[:file_name]}")
  end

  def not_unique
    redirect_to(new_secret_file_path(:error_duplicate_info=>"true"))
  end

  def accessible_files
    usernames_accessible = Array.new
    user_id = current_user.login.gsub("cb\\", "")
    list_to_add = SecretLinks.where("added_users=? and blessed=?", user_id, true).pluck(:username)
    coworker = ""
    sub = ""
    manager = "cb\\#{@@current_employee_data[:manager][:network_name]}"
    usernames_accessible.push(manager)
    @@current_employee_data[:coworkers].each do |element|
      coworker = "cb\\#{element[:network_name]}"
      usernames_accessible.push(coworker) unless usernames_accessible.include?(coworker)
    end
    @@current_employee_data[:subordinates].each do |element|
      sub = "cb\\#{element[:network_name]}"
      if (sub != user_id)
        usernames_accessible.push(sub) unless usernames_accessible.include?(sub)
      end
    end

    #users that invited you to see their files
    list_to_add.each do |element|
      usernames_accessible.push(element) unless usernames_accessible.include?(element)
    end
    usernames_accessible.push("#{current_user.login}")
    Rails.logger.info("current usernames accessible: #{usernames_accessible}")
    return usernames_accessible
  end

  def full_username
    return @@current_employee_data[:full_name]
  end

  def home_view
    user_id = current_user.login.gsub("cb\\", "")
    @@current_employee_data = @@employee_hash["#{user_id}"]
    refresh = refresh_employee_hash
    Rails.logger.info ("current employee data: #{@@current_employee_data}")
    return @@current_employee_data
  end

  def refresh_employee_hash
    list_to_remove = Array.new
    list_to_add = Array.new
    list_to_remove = SecretLinks.where("username=? and blessed=?", current_user.login, false).pluck(:added_users)
    list_to_add = SecretLinks.where("username=? and blessed=?", current_user.login, true).pluck(:added_users)
    list_to_remove.each do |remove|
        @@current_employee_data[:coworkers].each do |coworkers|
          if coworkers[:network_name] == remove
            @@current_employee_data[:coworkers].delete(coworkers)
          end
        end
        @@current_employee_data[:subordinates].each do |subordinates|
          if subordinates[:network_name] == remove
            @@current_employee_data[:subordinates].delete(subordinates)
          end
        end
    end

    @@current_employee_data[:additional_members] = Array.new
    list_to_add.each do |add|
      Rails.logger.info "adding"
      temp_to_add = @@employee_hash["#{add}"]
      @@current_employee_data[:additional_members].push(:network_name => temp_to_add[:network_name], :full_name => temp_to_add[:full_name], :job_title => temp_to_add[:job_title])
    end
  end

def self.get_technology_hash
  hash_to_display = @@employee_hash
  hash_to_display.delete(@@current_employee_data)
  return hash_to_display
end

  private
  def init
    if ((defined? @@employee_hash ) == nil || @@employee_hash.nil? || @@employee_hash.empty?)
      result = query_pi_rest_service("http://pi.careerbuilder.com/services/TeamFoundation/CBEmployee")
      Rails.logger.info result.length
      cto = result.find{|e| e[:HHRepID] == 'epresley'}
      technology_employees = subordinates(cto, result)
      @@employee_hash = build_employee_hash(technology_employees)
      end
    end

end
