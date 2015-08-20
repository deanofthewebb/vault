require 'rails_helper'
require 'rack/test'
require 'fakeweb'
require 'JSON'


RSpec.describe CbEmployeesController, :type => :controller do

    before(:each) {
      
      ApplicationController.any_instance.stub(:login).and_return(true)
      ApplicationController.any_instance.stub(:logout).and_return(true)
      file = File.new(Rails.root.join('spec/fixtures/files/response.txt'), "r")
      content = File.read(file)
      FakeWeb.register_uri(:get, "http://pi.careerbuilder.com/services/TeamFoundation/CBEmployee", :body => content)
      SecretLinks.destroy_all
      CbEmployees.destroy_all

    }

    let (:employee_data) do {
     "user" =>
     {
      network_name: "test.com",
      full_name: "user@test.com test",
      email: "user@test.com",
      :manager =>
      {
        network_name: "umanager",
        full_name: "umanager test",
        email: "umanager@test.com",
        job_title: "test manager"
      },
      :coworkers =>
      [
        {
          network_name: "coworker1",
          full_name: "coworker1 test",
          email: "coworker1@test.com",
          job_title: "coworker1 tester"
        },
        {
          network_name: "coworker2",
          full_name: "coworker2 test",
          email: "coworker2@test.com",
          job_title: "coworker2 tester"
        }
      ],
      :subordinates =>
      [
        {
          network_name: "subordinate1",
          full_name: "subordinate1 test",
          email: "subodinate1@test.com",
          job_title: "subordinate1 tester"
        },
        {
          network_name: "subordinate2",
          full_name: "subordinate2 test",
          email: "subordinate2@test.com",
          job_title: "subordinate2 tester"
        }
      ]
    },

      "subscriber" =>
      {
        network_name: "subscriber",
        full_name: "subscriber test",
        email: "subscriber@test.com",
        :manager =>
        {
        },
        :coworkers =>
        [],
        :subordinates =>
        []
      }
    }
  end


  let (:valid_attributes) do
      {
        full_name: "Test PlatformIntegrity",
        network_name: "user",
        email: "test@user.com",
        employee_id: "123",
        is_manager: false,
        job_title: "tester",
        manager: [],
        coworker: [],
        subordinates: [],
        additional_members: []
      }
    end


before (:each) do
    @user = User.create!({
      :login => "cb\\user",
      :password => 'please12345',
      :password_confirmation => 'please12345'
      })
    sign_in @user
  end

  describe "GET home" do
    it "returns http success" do
      CbEmployees.create! valid_attributes
      get :home
      expect(response).to be_success
    end
  end

  describe "test adding records in the cb_employee table " do

    it "creates a new cb_employee record" do
      employee = CbEmployees.create! valid_attributes
      expect(employee).to be_an_instance_of(CbEmployees)
    end

    it "fails with duplicate records in the table" do
      sec1 = CbEmployees.create! valid_attributes
      expect(lambda{CbEmployees.create! valid_attributes}).to raise_error
    end
  end

  describe "init" do
    it "initializes the run for the home view" do
      CbEmployeesController.any_instance.stub(:remove_missing_records).and_return(true)
      accessible_files = ["cb\\epresley", "cb\\atardo", "cb\\user", "cb\\dewebb", "cb\\cyoon", "cb\\elatimer", "cb\\asomda", "user"]
      CbEmployees.create(full_name: "to_remove", network_name: "tremove", employee_id: "0111")
      CbEmployeesController.class_variable_set(:@@employee_hash, nil)
      get :home
      current_employee_data = CbEmployees.where("network_name=?", "user")
      expect(CbEmployeesHelper.accessible_files("user", current_employee_data)).to eql(accessible_files)
    end
  end

  describe "full_username" do

    it "returns the current user's full name" do
    #CbEmployeesController.class_variable_set(:@@username, "tester")
    CbEmployees.create! valid_attributes
    uname = CbEmployeesController.full_username("cb\\user")
    expect(uname).to eql("Test PlatformIntegrity")
    end
  end
end
