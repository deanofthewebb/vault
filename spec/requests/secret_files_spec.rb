require 'rails_helper'

RSpec.describe "SecretFiles", :type => :request do

  describe "GET /secret_files" do
    it "works! (now write some real specs)" do
      get secret_files_path
      expect(response.status).to be(301)
    end
  end
end
