require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the CbEmployeesHelper. For example:
#
# describe CbEmployeesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe CbEmployeesHelper, :type => :helper do
	let (:response_hash) do
		[
			"test_data" =>
			{
				:HHRep => "tester",
				:EmployeeID => "001",
				:NetworkID => "ttester",
				:JobTitle => "test",
				:IsManager => false,
				:ReportToEmployeeID => "000"
			}
		]
	end
	let (:expected_response) do
			{
				"cfield" =>
				{
					:employee_id => "000",
					:network_name => "cfield",
					:full_name => "Colin Field",
					:email => "cfield@test.com",
					:job_title => "test",
					:is_manager => true,
					:coworkers => [],
					:subordinates =>
					[
						{
							:network_name => "cfield",
							:full_name => "Colin Field",
							:job_title => "test"
						},
						{
							:network_name => "wboatin",
							:full_name => "William Boatin",
							:job_title => "test"
						},
						{
							:network_name => "dewebb",
							:full_name => "Dean Webb",
							:job_title => "test"
						},
						{
							:network_name => "cyoon",
							:full_name => "Caleb Yoon",
							:job_title => "test"
						},
						{
							:network_name => "elatimer",
							:full_name => "Ethan Latimer",
							:job_title => "test"
						},
						{
							:network_name => "asomda",
							:full_name => "Arnaud Somda",
							:job_title => "test"
						},
						{
							:network_name => "atardo",
							:full_name => "Amy Tardo",
							:job_title => "test"
						}
					]
				},
				"wboatin" =>
				{
					:employee_id => "001",
					:network_name => "wboatin",
					:full_name => "William Boatin",
					:email => "wboatin@test.com",
					:job_title => "test",
					:is_manager => true,
					:manager => 
						{
							:network_name => "cfield",
							:full_name => "Colin Field",
							:job_title => "test"
						},
					:coworkers => 
						[
							{
								:network_name => "atardo",
								:full_name => "Amy Tardo",
								:job_title => "test"
							}
						],
					:subordinates =>
					[
						{
							:network_name => "wboatin",
							:full_name => "William Boatin",
							:job_title => "test"
						},
						{
							:network_name => "dewebb",
							:full_name => "Dean Webb",
							:job_title => "test"
						},
						{
							:network_name => "cyoon",
							:full_name => "Caleb Yoon",
							:job_title => "test"
						},
						{
							:network_name => "elatimer",
							:full_name => "Ethan Latimer",
							:job_title => "test"
						},
						{
							:network_name => "asomda",
							:full_name => "Arnaud Somda",
							:job_title => "test"
						}
					]

				},
				"atardo" =>
				{
					:employee_id => "002",
					:network_name => "atardo",
					:full_name => "Amy Tardo",
					:email => "atardo@test.com",
					:job_title => "test",
					:is_manager => false,
					:manager => 
						{
							:network_name => "cfield",
							:full_name => "Colin Field",
							:job_title => "test"
						},
					:coworkers => 
						[
							{
								:network_name => "wboatin",
								:full_name => "William Boatin",
								:job_title => "test"
							}
						],
					:subordinates =>
						[
							{
								:network_name => "atardo",
								:full_name => "Amy Tardo",
								:job_title => "test"
							}
						]
				},
				"dewebb" =>
				{
					:employee_id => "003",
					:network_name => "dewebb",
					:full_name => "Dean Webb",
					:email => "dewebb@test.com",
					:job_title => "test",
					:is_manager => false,
					:manager => 
						{
							:network_name => "wboatin",
							:full_name => "William Boatin",
							:job_title => "test"
						},
					:coworkers => 
						[
							{
								:network_name => "cyoon",
								:full_name => "Caleb Yoon",
								:job_title => "test"
							},
							{
								:network_name => "elatimer",
								:full_name => "Ethan Latimer",
								:job_title => "test"
							},
							{
								:network_name => "asomda",
								:full_name => "Arnaud Somda",
								:job_title => "test"
							}
						],
					:subordinates =>
						[
							{
							:network_name => "dewebb",
							:full_name => "Dean Webb",
							:job_title => "test"
							}
						]

				},
				"cyoon" =>
				{  
					:employee_id => "004",
					:network_name => "cyoon",
					:full_name => "Caleb Yoon",
					:email => "cyoon@test.com",
					:job_title => "test",
					:is_manager => false,
					:manager => 
						{
							:network_name => "wboatin",
							:full_name => "William Boatin",
							:job_title => "test"
						},
					:coworkers => 
						[
							{
								:network_name => "dewebb",
								:full_name => "Dean Webb",
								:job_title => "test"
							},
							{
								:network_name => "elatimer",
								:full_name => "Ethan Latimer",
								:job_title => "test"
							},
							{
								:network_name => "asomda",
								:full_name => "Arnaud Somda",
								:job_title => "test"
							}
						],
					:subordinates =>
						[
							{
								:network_name => "cyoon",
								:full_name => "Caleb Yoon",
								:job_title => "test"
							}
						]
				},
				"elatimer" =>
				{ 
					:employee_id => "005",
					:network_name => "elatimer",
					:full_name => "Ethan Latimer",
					:email => "elatimer@test.com",
					:job_title => "test",
					:is_manager => false,
					:manager => 
						{
							:network_name => "wboatin",
							:full_name => "William Boatin",
							:job_title => "test"
						},
					:coworkers => 
						[
							{
								:network_name => "dewebb",
								:full_name => "Dean Webb",
								:job_title => "test"
							},
							{
								:network_name => "cyoon",
								:full_name => "Caleb Yoon",
								:job_title => "test"
							},
							{
								:network_name => "asomda",
								:full_name => "Arnaud Somda",
								:job_title => "test"
							}
						],
					:subordinates =>
						[
							{
								:network_name => "elatimer",
								:full_name => "Ethan Latimer",
								:job_title => "test"
							}
						] 

				},
				"asomda" =>
				{ 
					:employee_id => "006",
					:network_name => "asomda",
					:full_name => "Arnaud Somda",
					:email => "asomda@test.com",
					:job_title => "test",
					:is_manager => false,
					:manager => 
						{
							:network_name => "wboatin",
							:full_name => "William Boatin",
							:job_title => "test"
						},
					:coworkers => 
						[
							{
								:network_name => "dewebb",
								:full_name => "Dean Webb",
								:job_title => "test"
							},
							{
								:network_name => "cyoon",
								:full_name => "Caleb Yoon",
								:job_title => "test"
							},
							{
								:network_name => "elatimer",
								:full_name => "Ethan Latimer",
								:job_title => "test"
							}
						],
					:subordinates =>
						[
							{
								:network_name => "asomda",
								:full_name => "Arnaud Somda",
								:job_title => "test"
							}
						]  

				}
			}

		end

	let (:employees_data) do
		[
			{
				:EmployeeID => "000",
				:HHRepID => "cfield",
				:FirstName => "Colin",
				:LastName => "Field",
				:Email => "cfield@test.com",
				:JobTitle => "test",
				:IsAManager => true,
				:ReportToEmployeeID => "",

			},
			{
				:EmployeeID => "001",
				:HHRepID => "wboatin",
				:FirstName => "William",
				:LastName => "Boatin",
				:Email => "wboatin@test.com",
				:JobTitle => "test",
				:IsAManager => true,
				:ReportToEmployeeID => "000",
			},
			{
				:EmployeeID => "002",
				:HHRepID => "atardo",
				:FirstName => "Amy",
				:LastName => "Tardo",
				:Email => "atardo@test.com",
				:JobTitle => "test",
				:IsAManager => false,
				:ReportToEmployeeID => "000",
			},
			{
				:EmployeeID => "003",
				:HHRepID => "dewebb",
				:FirstName => "Dean",
				:LastName => "Webb",
				:Email => "dewebb@test.com",
				:JobTitle => "test",
				:IsAManager => false,
				:ReportToEmployeeID => "001",
			},
			{
				:EmployeeID => "004",
				:HHRepID => "cyoon",
				:FirstName => "Caleb",
				:LastName => "Yoon",
				:Email => "cyoon@test.com",
				:JobTitle => "test",
				:IsAManager => false,
				:ReportToEmployeeID => "001",
			},
			{
				:EmployeeID => "005",
				:HHRepID => "elatimer",
				:FirstName => "Ethan",
				:LastName => "Latimer",
				:Email => "elatimer@test.com",
				:JobTitle => "test",
				:IsAManager => false,
				:ReportToEmployeeID => "001",
			},
			{
				:EmployeeID => "006",
				:HHRepID => "asomda",
				:FirstName => "Arnaud",
				:LastName => "Somda",
				:Email => "asomda@test.com",
				:JobTitle => "test",
				:IsAManager => false,
				:ReportToEmployeeID => "001",
			}
		]
	end

	describe "symbolize_hash_array" do
		it "returns the symbolized hash" do
			sym_hash = CbEmployeesHelper.symbolize_hash_array(response_hash)
			expect(sym_hash[0][:test_data]).not_to eql(nil)
		end
	end

	describe "subordinates" do
		let (:expected_response) do
			[

				{
					:EmployeeID => "001",
					:HHRepID => "wboatin",
					:FirstName => "William",
					:LastName => "Boatin",
					:Email => "wboatin@test.com",
					:JobTitle => "test",
					:IsAManager => true,
					:ReportToEmployeeID => "000",
				},
				{
					:EmployeeID => "003",
					:HHRepID => "dewebb",
					:FirstName => "Dean",
					:LastName => "Webb",
					:Email => "dewebb@test.com",
					:JobTitle => "test",
					:IsAManager => false,
					:ReportToEmployeeID => "001",
				},
				{
					:EmployeeID => "004",
					:HHRepID => "cyoon",
					:FirstName => "Caleb",
					:LastName => "Yoon",
					:Email => "cyoon@test.com",
					:JobTitle => "test",
					:IsAManager => false,
					:ReportToEmployeeID => "001",
				},
				{
					:EmployeeID => "005",
					:HHRepID => "elatimer",
					:FirstName => "Ethan",
					:LastName => "Latimer",
					:Email => "elatimer@test.com",
					:JobTitle => "test",
					:IsAManager => false,
					:ReportToEmployeeID => "001",
				},
				{
					:EmployeeID => "006",
					:HHRepID => "asomda",
					:FirstName => "Arnaud",
					:LastName => "Somda",
					:Email => "asomda@test.com",
					:JobTitle => "test",
					:IsAManager => false,
					:ReportToEmployeeID => "001",
				}
			]
		end
		it "returns the list of subordinates of the user" do
			subordinates = CbEmployeesHelper.subordinates(employees_data[1], employees_data)
			expect(subordinates).to eql(expected_response)
		end
	end

	describe " build_employee_hash" do

		it "builds the employee hash based on the response received" do
			tech_hash = CbEmployeesHelper.build_employee_hash(employees_data)
			expect(tech_hash).to eql(expected_response)
		end

		it "builds individual employees hash" do
			emp_record = CbEmployeesHelper.create_employee(employees_data[6], employees_data)
			expect(emp_record).to eql(expected_response["asomda"])
		end
	end

	describe "refresh_additional_employees" do
			let (:new_employee_record) do
				[
					{
						network_name: "atardo",
						full_name: "Amy Tardo",
						job_title: "test"
					},
					{
						network_name: "cfield",
						full_name: "Colin Field",
						job_title: "test"
					}
				]
			end
		it "ensures that all the records in the SecretLinks table are added as additional users" do
				CbEmployees.create(full_name: expected_response["asomda"][:full_name],
								network_name: expected_response["asomda"][:network_name],
								job_title: expected_response["asomda"][:job_title],
								is_manager: expected_response["asomda"][:is_manager],
								email: expected_response["asomda"][:email],
								manager: expected_response["asomda"][:manager],
								coworker: expected_response["asomda"][:coworkers],
								subordinates: expected_response["asomda"][:subordinates]
							)
			current_employee_data = expected_response["asomda"]
			current_user = "cb\\asomda"
			SecretLinks.create(username: "cb\\asomda", added_users: "atardo", blessed: true)
			SecretLinks.create(username: "cb\\asomda", added_users: "cfield", blessed: true)
			CbEmployeesHelper.refresh_additional_employees(expected_response, current_employee_data, current_user)
			new_record = CbEmployees.where("network_name=?", "asomda").first
			expect(new_record[:additional_members]).to eql(new_employee_record)
		end
	end

	describe "accessible files" do
		let(:accessible_array) do
			["cb\\cfield", "cb\\wboatin", "cb\\atardo", "cb\\asomda"]
	end
		it "returns the set of currently available files to view for one user" do
			CbEmployees.create(full_name: expected_response["asomda"][:full_name],
								network_name: expected_response["asomda"][:network_name],
								job_title: expected_response["asomda"][:job_title],
								is_manager: expected_response["asomda"][:is_manager],
								email: expected_response["asomda"][:email],
								manager: expected_response["asomda"][:manager],
								coworker: expected_response["asomda"][:coworkers],
								subordinates: expected_response["asomda"][:subordinates]
							)
			CbEmployees.create(full_name: expected_response["atardo"][:full_name],
								network_name: expected_response["atardo"][:network_name],
								job_title: expected_response["atardo"][:job_title],
								is_manager: expected_response["atardo"][:is_manager],
								email: expected_response["atardo"][:email],
								manager: expected_response["atardo"][:manager],
								coworker: expected_response["atardo"][:coworkers],
								subordinates: expected_response["atardo"][:subordinates]
							)
			SecretLinks.create(username: "cb\\asomda", added_users: "atardo", blessed: true)
			current_employee_data = CbEmployees.where("network_name=?", "atardo")
			access_array = CbEmployeesHelper.accessible_files("cb\\atardo", current_employee_data)
			expect(access_array).to eql(accessible_array)
		end
	end

	describe "recursive_access" do
		sub_expected = ["cfield", "wboatin", "dewebb", "cyoon", "elatimer", "asomda", "atardo"]
		it "it returns all the subordinates from the user sent in" do
			sub_array = CbEmployeesHelper.recursive_access("cfield", expected_response)
			expect(sub_array).to eql(sub_expected)
		end
	end
  

  describe "filter" do
  	let (:add_params) do 
  		{
  			add: "adder",
  			recursive: "0",
  			added_user: "atardo"
  		}
  	end

  	let(:rec_add_params) do
  		{
  			add: "adder",
  			recursive: "1",
  			added_user: "wboatin"
  		}
  	end

  	let(:rem_params) do
  		{
  			add: "remover",
  			recursive: "0",
  			added_user: "dewebb"
  		}
  	end

  	let(:rec_rem_params) do
  		{
  			add: "remover",
  			recursive: "1",
  			added_user: "wboatin"
  		}
  	end

  	it "adds a viewers/subscribers to the current user" do
  		CbEmployees.create(full_name: expected_response["asomda"][:full_name],
								network_name: expected_response["asomda"][:network_name],
								job_title: expected_response["asomda"][:job_title],
								is_manager: expected_response["asomda"][:is_manager],
								email: expected_response["asomda"][:email],
								manager: expected_response["asomda"][:manager],
								coworker: expected_response["asomda"][:coworkers],
								subordinates: expected_response["asomda"][:subordinates]
							)
  		CbEmployeesHelper.filter("cb\\asomda", expected_response, add_params)
  		new_link = SecretLinks.where("username=? and added_users=? and blessed=?", "cb\\asomda", "atardo", true).first
  		expect(new_link).not_to eql(nil)
  	end

  	it "recursively add viewers to the current user" do
  		CbEmployees.create(full_name: expected_response["atardo"][:full_name],
								network_name: expected_response["atardo"][:network_name],
								job_title: expected_response["atardo"][:job_title],
								is_manager: expected_response["atardo"][:is_manager],
								email: expected_response["atardo"][:email],
								manager: expected_response["atardo"][:manager],
								coworker: expected_response["atardo"][:coworkers],
								subordinates: expected_response["atardo"][:subordinates]
							)
  		CbEmployeesHelper.filter("cb\\atardo", expected_response, rec_add_params)
  		list_of_subscribers = SecretLinks.where("username=? and blessed=?", "cb\\atardo", true).to_a.map(&:serializable_hash)
  		expect(list_of_subscribers.length).to eql(5)
  	end

  	it "removes a user from seeing the current user's files" do
  		CbEmployees.create(full_name: expected_response["asomda"][:full_name],
								network_name: expected_response["asomda"][:network_name],
								job_title: expected_response["asomda"][:job_title],
								is_manager: expected_response["asomda"][:is_manager],
								email: expected_response["asomda"][:email],
								manager: expected_response["asomda"][:manager],
								coworker: expected_response["asomda"][:coworkers],
								subordinates: expected_response["asomda"][:subordinates]
							)
  		CbEmployeesHelper.filter("cb\\asomda", expected_response, rem_params)
  		list_of_subscribers = SecretLinks.where("username=? and blessed=?", "cb\\asomda", false).to_a.map(&:serializable_hash)
  		expect(list_of_subscribers.length).to eql(1)
  	end
  	it "removes a user from seeing the current user's files" do
  		CbEmployees.create(full_name: expected_response["asomda"][:full_name],
								network_name: expected_response["asomda"][:network_name],
								job_title: expected_response["asomda"][:job_title],
								is_manager: expected_response["asomda"][:is_manager],
								email: expected_response["asomda"][:email],
								manager: expected_response["asomda"][:manager],
								coworker: expected_response["asomda"][:coworkers],
								subordinates: expected_response["asomda"][:subordinates]
							)
  		CbEmployeesHelper.filter("cb\\asomda", expected_response, rec_rem_params)
  		list_of_subscribers = SecretLinks.where("username=? and blessed=?", "cb\\asomda", false).to_a.map(&:serializable_hash)
  		expect(list_of_subscribers.length).to eql(5)
  	end
  end
end
