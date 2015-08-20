class SecretFilesController < ApplicationController
  helper_method :set_params_delete_var_false
  rescue_from ActiveRecord::RecordNotUnique, with: :not_unique
  skip_before_filter :authenticate_user!, :only => [:view]

  include SecretFilesHelper
  # GET /secret_files
  # GET /secret_files.xml

  def index
    @secret_files = ""
    user_id = current_user.login.gsub("cb\\", "")
    current_employee_data = CbEmployees.where("network_name=?", user_id)
    array_to_check = CbEmployeesHelper.accessible_files(current_user.login, current_employee_data)
    if SecretFilesHelper.validate_user(current_user.login, "")
      @secret_files = SecretFile.all
      Rails.logger.info "#{current_user.login} signed in at #{Time.now}"
    else

      @secret_files = SecretFile.where({ login: array_to_check})
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
    raise "non authorized user, #{current_user.login} not admin nor not equal to #{@secret_file.login}" unless SecretFilesHelper.validate_user(current_user.login, @secret_file)
    respond_to do |format|
      format.html       # show.html.erb
      format.xml  { render :xml => @secret_file }
    end
    send_file "public/data/#{formatted_file}", :filename => "#{@secret_file[:file_name]}"
  end

  def help
  end

  def about
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
    raise "non authorized user, #{current_user.login} not admin nor not equal to #{@secret_file.login}" unless SecretFilesHelper.validate_user(current_user.login, @secret_file)
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
    raise "non authorized user, #{current_user.login} not admin nor not equal to #{@secret_file.login}" unless SecretFilesHelper.validate_user(current_user.login, @secret_file)
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
      if(CbEmployees.where("network_name=?", params[:owner][0]).empty?)
        flash[:alert]="The user you have entered does not exists in the current employee table"
        redirect_to(secret_files_url)
        return
      end
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

end
