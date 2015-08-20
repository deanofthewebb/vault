require 'rails_helper'
describe "User tests" do
  describe "email_required?" do
    it "should not expect an email" do
      used = User.new
      expect(used.email_required?).to eql(false)
    end
  end
  describe "email changed" do
    it "should not be changed" do
      used = User.new
      expect(used.email_changed?).to eql(false)
    end
  end
end