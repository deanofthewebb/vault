class CbEmployees < ActiveRecord::Base
	serialize :manager
	serialize :coworker
	serialize :subordinates
	serialize :additional_members
end
