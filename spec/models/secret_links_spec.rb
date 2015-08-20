require 'rails_helper'

RSpec.describe SecretLinks, :type => :model do
  # pending "add some examples to (or delete) #{__FILE__}"

  describe "add a record" do

  	it "adds a simple record to the secret_links table" do
  		SecretLinks.create(username: "test", added_users: "subscribers", blessed: true)
  		record = SecretLinks.where("username=? and added_users=? and blessed=?", "test", "subscribers", true).first
  		expect(record).not_to eql(nil)
  	end

  	it "does allow duplicate records in the table" do
  		SecretLinks.create(username: "test", added_users: "subscribers", blessed: true)
  		expect(lambda{SecretLinks.create(username: "test", added_users: "subscribers", blessed: true)}).to raise_error
  	end
  end
end
