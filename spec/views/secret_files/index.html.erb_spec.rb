require 'rails_helper'

RSpec.describe "secret_files/index", :type => :view do
  before(:each) do
    assign(:secret_files, [
      SecretFile.create!(),
      SecretFile.create!()
    ])
  end

  it "renders a list of secret_files" do
    render
  end
end
