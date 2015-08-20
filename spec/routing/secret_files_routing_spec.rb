require "rails_helper"

RSpec.describe SecretFilesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/secret_files").to route_to("secret_files#index")
    end

    it "routes to #new" do
      expect(:get => "/secret_files/new").to route_to("secret_files#new")
    end

    it "routes to #show" do
      expect(:get => "/secret_files/1").to route_to("secret_files#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/secret_files/1/edit").to route_to("secret_files#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/secret_files").to route_to("secret_files#create")
    end

    it "routes to #update" do
      expect(:put => "/secret_files/1").to route_to("secret_files#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/secret_files/1").to route_to("secret_files#destroy", :id => "1")
    end

  end
end
