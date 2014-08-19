class Trader < ActiveRecord::Base
	attr_accessible :brocker, :name, :account, :registration_date, :tp, :investor_percent, 
					:pamm2, :min_value
end
