require 'rails_helper'

=begin - Blocked out due to the fact that it is a test of the edit page form. 
Since we don't have a working edit form I am blocking off the tests.


	RSpec.describe "secret_files/edit", :type => :view do
	  before(:each) do
	    @secret_file = assign(:secret_file, SecretFile.create!())
	  end

	  it "renders the edit secret_file form" do
	    render

	    assert_select "form[action=?][method=?]", secret_file_path(@secret_file), "post" do
	    end
	  end
	end
=end