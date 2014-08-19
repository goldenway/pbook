class PortfolioWeek < ActiveRecord::Base
	attr_accessible :week_type, :date, :start_value, :end_value, :free_cash, :comment

	belongs_to :portfolio
	has_many :portfolio_traders, dependent: :destroy
end
