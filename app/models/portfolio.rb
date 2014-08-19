class Portfolio < ActiveRecord::Base
	attr_accessible :name, :rating

	belongs_to :user
	has_many :portfolio_weeks, dependent: :destroy
end
