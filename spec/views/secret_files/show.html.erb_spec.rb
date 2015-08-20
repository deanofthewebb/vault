require 'rails_helper'

RSpec.describe "secret_files/show", :type => :view do
  before(:each) do
    @secret_file = assign(:secret_file, SecretFile.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
