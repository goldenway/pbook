class PortfolioWeeksController < ApplicationController
	def show
		@user = current_user
		# @portfolio_week = PortfolioWeek.find(params[:id])

		@portfolio = current_user.portfolios[0]
	end
end
