require 'rails_helper'
require 'spec_helper'

RSpec.describe "secret_files/new", :type => :view do
  before(:each) do
    assign(:secret_file, SecretFile.new())
  end
=begin - due to changes this is no longer applicable, will build from scratch later.
  it "renders new secret_file form" do
    render

    assert_select "form[action=?][method=?]", secret_files_path, "post" do
    end
  end
=end
end
