class PortfoliosController < ApplicationController

# TODO: remove this action
	def index
		@current_portfolio = Portfolio.find(1)
		@current_week = @current_portfolio.portfolio_weeks.last
		@portfolio_traders = @current_week.portfolio_traders
	end
# end

	def show_portfolio_data
		@current_portfolio = Portfolio.find_by_name(params[:portfolio_name])
		@current_week = @current_portfolio.portfolio_weeks.last
		@portfolio_traders = @current_week.portfolio_traders
	end

	def hide_portfolio_data
	end
end
