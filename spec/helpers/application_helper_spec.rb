require 'rails_helper'

Rails.describe ApplicationHelper, :type => :helper do
  describe "full_title" do
    it "should return 'PI Vault'" do
      include ApplicationHelper
      expect(full_title("")).to eql("PI Vault")
    end
    it "should return 'PI Vault | Adjusted!'" do
      include ApplicationHelper
      expect(full_title("Adjusted!")).to eql("PI Vault | Adjusted!")
    end
  end
end