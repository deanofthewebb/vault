class SecretFile < ActiveRecord::Base
	belongs_to :users
	has_attached_file :attachment
	do_not_validate_attachment_file_type :attachment
	attr_accessor :attachment_file_name

  before_validation {file.clear if @delete_file}
end
