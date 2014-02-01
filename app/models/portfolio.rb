class Portfolio < ActiveRecord::Base
	attr_accessible :name, :rating, :comment

	belongs_to :user
	has_many :portfolio_weeks
end
