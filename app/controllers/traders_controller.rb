class TradersController < ApplicationController
	def index
	end

	def add_to_portfolio
		@portfolio_names = params[:portfolio_names]
		
		@portfolio_names.each do |portfolio_name|
			portfolio = Portfolio.find_by_name(portfolio_name)
			portfolio_last_week = portfolio.portfolio_weeks.last
			added_portfolio_trader = portfolio_last_week.portfolio_traders.build(trader_account: params[:trader_account].to_i, 
																				 start_value: 25,
																				 end_value: 30)
			added_portfolio_trader.save
		end
	end

	def test_ajax
		# respond_to do |format|
		# 	format.html { redirect_to root_path }
		# 	format.js
		# end
	end

	def test_get
	end

	def test_post
	end
end
