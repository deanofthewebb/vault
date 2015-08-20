require 'rails_helper'

Rails.describe SecretFilesHelper, :type => :helper do
  include SecretFilesHelper

  valid_params = [{:file_name => "secret_file.txt", :environment => "environment", :role => "role" , :key => "abc123"}]
  before(:each) do
      SecretFilesHelper.stub(:system).and_return(true)
      File.stub(:exist?).and_return(true)
    end
 let(:valid_new_file_attr) do {
      id: 1,
      environment: "test",
      login: "test@user.com",
      role: "base",
      :attachment => Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/secret_file.txt'), 'secret_file/txt')
    }
  end

    let(:valid_edit_file_attr) do {
      id: 1,
      secret_file: {
        :secret_file => fixture_file_upload('files/secret_file.txt', 'text'),
        :environment => "test",
        :role => "base",
        :login => "user@test.com",
        :attachment => Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/secret_file.txt'), 'secret_file/txt')
      },
      owner: "user@test.com"
    }
  end

   let(:invalid_edit_file_attr) do {
      :secret_file => {
        login: "user@test.com"
      }
    }
  end

  describe "create_json" do
    it "should return the string value of the name of the file" do
      expect(SecretFilesHelper.create_json(fixture_file_upload('files/secret_file.txt', 'text'), valid_params)).to eq("public/data/environment_role_secret_file.txt.json") 
    end

    it "should create the file in the correct location as a json file" do
      SecretFilesHelper.create_json(fixture_file_upload('files/secret_file.txt', 'text'), valid_params)
      expect(File.exists?('public/data/environment_role_secret_file.txt.json')).to eq(true)
      File.delete('public/data/environment_role_secret_file.txt.json')
    end

    it "should format into json correctly" do
      SecretFilesHelper.create_json(fixture_file_upload('files/secret_file.txt', 'text'), valid_params)
      binary_representation = fixture_file_upload('files/secret_file.txt', 'text').read.unpack('h*')
      file_name = valid_params[0][:environment] + "_" + valid_params[0][:role] + "_" + valid_params[0][:file_name] 
      File.open('public/data/tempfile.json', 'wb') do |f|
        f.puts("{")
        f.puts("  \"id\":\"" << file_name << "\",")
        f.puts("  \"file_name\":\"" << valid_params[0][:file_name] << "\",")
        f.puts("  \"data\":" << binary_representation.to_s)
        f.puts("}")
      end
      expect(FileUtils.compare_file('public/data/environment_role_secret_file.txt.json', 'public/data/tempfile.json')).to eq(true)
      File.delete('public/data/tempfile.json')
      File.delete('public/data/environment_role_secret_file.txt.json')
    end

  end

  describe "validate_user" do
  let(:valid_attributes) do {
    id: 1,
    file_name: "secret_file.txt",
    environment: "environment",
    role: "role",
    login: "cb\\user@test.com",
    :attachment => Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/secret_file.txt'), 'secret_file/txt')
  }end

  before(:each) do
    CbEmployees.create(:full_name => "user@test.com",
                        :network_name => "user@test.com",
                        :email => "usertester@test.com",
                        :job_title => "usertester",
                        :is_manager => false,
                        :manager => {},
                        :coworker => [],
                        :subordinates => [])

    CbEmployees.create(:full_name => "elatimer@test.com",
                        :network_name => "elatimer",
                        :email => "elatimertester@test.com",
                        :job_title => "elattester",
                        :is_manager => false,
                        :manager => {},
                        :coworker => [],
                        :subordinates => [])

    CbEmployees.create(:full_name => "tester@test.com",
                        :network_name => "tester",
                        :email => "tester@test.com",
                        :job_title => "tester",
                        :is_manager => false,
                        :manager => {},
                        :coworker => [],
                        :subordinates => [])

  end
    array_to_check = ["cb\\umanager", "cb\\coworker1", "cb\\coworker2", "cb\\subordinate1", "cb\\subordinate2", "cb\\user@test.com"]


    it "ensures that a user has access to his file" do 
      secret = SecretFile.create! valid_attributes
      expect(SecretFilesHelper.validate_user("cb\\user@test.com", secret)).to eql(true)
    end

    it "ensures that an admin user can access all the files" do
      secret = SecretFile.create! valid_attributes
      expect(SecretFilesHelper.validate_user("cb\\elatimer", secret)). to eql(true)
    end

    it "ensures that users do cannot access unauthorized files" do
      secret = SecretFile.create! valid_attributes
      expect(SecretFilesHelper.validate_user("cb\\tester", secret)).to eql(false)
    end

    it "ensures that admin user can access all files" do

    end
  end

  describe "new_and_edit_file" do
    let(:valid_attributes) do {
    id: 1,
    file_name: "secret_file.txt",
    environment: "environment",
    role: "role",
    login: "user@test.com",
    :attachment => Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/secret_file.txt'), 'secret_file/txt')
  }
end
    it "uploads or creates a new secret file" do
       delete = false
       expect(SecretFilesHelper).to receive(:knife_upload)
       expect(SecretFilesHelper).to receive(:backup_secret)
       SecretFilesHelper.new_and_edit_file(valid_edit_file_attr , valid_params[0][:key], valid_edit_file_attr[:secret_file][:login], delete)
       secret = SecretFile.find(1)
       expect(secret).to be_a(SecretFile)
    end
    it "uploads or creates a new secret file" do
       delete = true
       expect(SecretFilesHelper).to receive(:knife_upload)
       expect(SecretFilesHelper).to receive(:backup_secret)
       secret = SecretFile.create! valid_attributes
       SecretFilesHelper.new_and_edit_file(valid_edit_file_attr , valid_params[0][:key], valid_edit_file_attr[:secret_file][:login], delete)
       expect(secret).to be_a(SecretFile)
    end

    it "should fail uploading the data due to invalid arguments" do
      delete = false
      expect(lambda {SecretFilesHelper.new_and_edit_file(invalid_edit_file_attr, valid_params[0][:key], valid_edit_file_attr[:secret_file][:login], delete)}).to raise_error(NoMethodError)
    end
  end

  describe "edit_file" do
    let(:valid_attributes) do {
    id: 1,
    file_name: "secret_file.txt",
    environment: "Environment",
    role: "role",
    login: "user@test.com",
    :attachment => Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/secret_file.txt'), 'secret_file/txt')
  }end


  it "Should edit a already uploaded file" do
    parameters = valid_edit_file_attr[:secret_file]
    secret = SecretFile.create! valid_attributes
    expect(File).to receive(:new).and_return(Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/secret_file.txt'), 'secret_file/txt'))
    expect(SecretFilesHelper).to receive(:knife_delete)
    expect(SecretFilesHelper).to receive(:knife_upload)
    expect(SecretFilesHelper).to receive(:backup_secret)
    SecretFilesHelper.edit_file(valid_edit_file_attr, SecretFile.find(secret[:id]), valid_params[0][:key], valid_edit_file_attr[:secret_file][:login])
    secret_file = SecretFile.find(secret[:id])
    expect(secret_file[:environment]).to eq("test")
  end

  it "should result in an error due to invalid arguments" do
    secret = SecretFile.create! valid_attributes
    expect(File).to receive(:new).and_return(Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/secret_file.txt'), 'secret_file/txt'))
    expect(lambda{SecretFilesHelper.edit_file(invalid_edit_file_attr, SecretFile.find(secret[:id]), valid_params[0][:key], valid_edit_file_attr[:secret_file][:login])}).to raise_error()
  end
end

  describe "as array" do
    it "takes in a string object and return an object of class array" do
      expect(SecretFilesHelper.as_array("hello there").class).to eql(Array)
    end

    it "takes in an array and return an array" do
      array_test = Array["1","2"]
      expect(SecretFilesHelper.as_array(array_test).class).to eql(Array)
    end
  end


  describe "collect_secret_from_backup" do
    let(:valid_attributes) do {
      id: 1,
      file_name: "secret_file.txt",
      environment: "environment",
      role: "role",
      login: "cb\\user@test.com",
      :attachment => Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/secret_file.txt'), 'secret_file/txt')
    }end

    it "fails downloading the file from artifactory since it doesn't exist" do
      secret = SecretFile.create! valid_attributes
      expect{lambda (SecretFilesHelper.decrypt_and_store_secret(secret))}.to raise_error()
    end

    it "downloads an existing file in artifactory" do
      secret_file = SecretFile.create! valid_attributes
      time = (!secret_file[:updated_at].blank? && secret_file[:updated_at]) || secret_file[:created_at]
      SecretFilesHelper.backup_secret(time, secret_file[:file_name], (Rails.root.join('spec/fixtures/files/secret_file.txt')), secret_file[:environment], secret_file[:role], secret_file[:login])
      SecretFilesHelper.collect_secret_from_backup(secret_file)
      time = time.localtime.strftime('%H%M')
      file_name = "public/data/environment_role_cb_user@test.com_secret_file_#{time}.txt"
      Helper.file_writer(file_name, "just a trial")
      File.open(Rails.root.join("#{file_name}"))
      expect(File.exist?(Rails.root.join("#{file_name}"))).to eql(true)
      File.delete(Rails.root.join("#{file_name}"))
    end
  end

  after(:all) do
    system("rm -rf #{Rails.root.join('public/data')}")
    system("mkdir #{Rails.root.join('public/data')}")
  end
end

module Helper
  def self.file_writer(filename, contents)
    file_to_write = File.new(Rails.root.join("#{filename}"), "w")
    file_to_write.write(contents)

  end
end
