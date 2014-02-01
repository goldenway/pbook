class PortfolioWeek < ActiveRecord::Base
	attr_accessible :profit

	belongs_to :portfolio
	has_many :portfolio_traders
end
