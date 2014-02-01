class Trader < ActiveRecord::Base
	attr_accessible :account, :brocker, :investor_percent, :min_value, :name, :pamm2, 
					:registration_date, :tp
end
