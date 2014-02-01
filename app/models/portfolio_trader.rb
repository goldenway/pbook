class PortfolioTrader < ActiveRecord::Base
	attr_accessible :trader_account, :start_value, :end_value

	belongs_to :portfolio_week
end
