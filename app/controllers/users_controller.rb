class UsersController < ApplicationController
	before_filter :signed_in_user, only: [:index, :show, :edit, :update, :destroy]
	before_filter :unsigned_user,  only: [:new, :create]
	before_filter :correct_user,   only: [:edit, :update]
	before_filter :admin_user,     only: :destroy

	# REST methods ======================================================================

	def index
		@users = User.paginate(page: params[:page], per_page: 10)
	end

	def show
		@user = current_user

		@current_portfolio = session[:current_portfolio_name] ? Portfolio.find_by_name(session[:current_portfolio_name]) : current_user.portfolios[0]
		session[:current_portfolio_name] = @current_portfolio.name
		
		if @current_portfolio.portfolio_weeks.any?
			@current_week = @current_portfolio.portfolio_weeks.last
			session[:current_week_id] = @current_week.id

			@portfolio_traders = @current_week.portfolio_traders

			# total profit
			totals = total_profit_for(current_user, @current_week)
			@total_cash = totals[0]
			@total_percent = totals[1]
		else
			@portfolio_traders = []
		end
	end
	
	def new
		@user = User.new
	end

	def create
		@user = User.new(params[:user])
		if @user.save
			sign_in @user
			flash[:success] = "Welcome to PammBook"
			redirect_to @user
		else
			render 'new'
		end
	end

	def edit
	end

	def update
		if @user.update_attributes(params[:user])
			flash[:success] = "Profile updated"
			sign_in @user
			redirect_to @user
		else
			render 'edit'
		end
	end

	def destroy
		User.find(params[:id]).destroy
		flash[:success] = "User destroyed"
		redirect_to users_url
	end

	# page initialization methods =======================================================

	def get_init_data
		@current_portfolio = session[:current_portfolio_name] ? Portfolio.find_by_name(session[:current_portfolio_name]) : current_user.portfolios[0]

		if @current_portfolio.portfolio_weeks.any?
			@current_week = session[:current_week_id] ? PortfolioWeek.find(session[:current_week_id]) : @current_portfolio.portfolio_weeks.last

			# week traders for charts
			@portfolio_week_traders = current_portfolio_traders_for_week(@current_week)
			@all_week_traders = all_portfolios_traders_for_week(@current_week)

			@portfolio_traders = @current_week.portfolio_traders
		else
			@portfolio_traders = []
		end

		@history_profit = history_profit()
	end

	# methods with portfolios ===========================================================

	def select_portfolio
		@current_portfolio = Portfolio.find_by_name(params[:portfolio_name])
		session[:current_portfolio_name] = params[:portfolio_name]

		if @current_portfolio.portfolio_weeks.any?
			@current_week = @current_portfolio.portfolio_weeks.last

			# select current week in selected portfolio
			previous_portfolio_week = PortfolioWeek.find(session[:current_week_id]) if session[:current_week_id]
			if previous_portfolio_week
				@current_portfolio.portfolio_weeks.each do |portfolio_week|
					if portfolio_week.date && previous_portfolio_week.date && portfolio_week.date.strftime("%d.%m.%Y") == previous_portfolio_week.date.strftime("%d.%m.%Y")
						@current_week = portfolio_week
					end
				end
			end

			session[:current_week_id] = @current_week.id

			# week traders for charts
			@portfolio_week_traders = current_portfolio_traders_for_week(@current_week)
			@all_week_traders = all_portfolios_traders_for_week(@current_week)

			@portfolio_traders = @current_week.portfolio_traders

			# total profit
			totals = total_profit_for(current_user, @current_week)
			@total_cash = totals[0]
			@total_percent = totals[1]
		else
			@portfolio_traders = []
		end
	end

	def create_portfolio
		@portfolio_name = params[:portfolio_name]

		new_portfolio = current_user.portfolios.build(name: params[:portfolio_name],
													  rating: 0.0)
		new_portfolio.save

		@current_portfolio = new_portfolio
		session[:current_portfolio_name] = @current_portfolio.name
		session.delete(:current_week_id)

		@portfolio_traders = []
	end

	def remove_portfolio
		@portfolio_name = params[:portfolio_name]

		Portfolio.find_by_name(params[:portfolio_name]).destroy

		@current_portfolio = session[:current_portfolio_name] == params[:portfolio_name] ? current_user.portfolios[0] : Portfolio.find_by_name(session[:current_portfolio_name])
		session[:current_portfolio_name] = @current_portfolio.name

		if @current_portfolio.portfolio_weeks.any?
			@current_week = @current_portfolio.portfolio_weeks.last
			session[:current_week_id] = @current_week.id

			# week traders for charts
			@portfolio_week_traders = current_portfolio_traders_for_week(@current_week)
			@all_week_traders = all_portfolios_traders_for_week(@current_week)

			@portfolio_traders = @current_week.portfolio_traders

			# total profit
			totals = total_profit_for(current_user, @current_week)
			@total_cash = totals[0]
			@total_percent = totals[1]
		else
			@portfolio_traders = []
		end

		@history_profit = history_profit()
	end

	# methods with weeks ================================================================

	def select_week
		@is_selected_new_week = true if params[:week_id] != session[:current_week_id]
		if @is_selected_new_week
			@current_week = PortfolioWeek.find(params[:week_id])
			session[:current_week_id] = params[:week_id]

			# week traders for charts
			@portfolio_week_traders = current_portfolio_traders_for_week(@current_week)
			@all_week_traders = all_portfolios_traders_for_week(@current_week)

			@portfolio_traders = @current_week.portfolio_traders

			# TODO: remove if not need
			@traders = []
			@portfolio_traders.all.each do |portfolio_trader|
				@traders.push Trader.find_by_account(portfolio_trader.trader_account)
			end

			# total profit
			totals = total_profit_for(current_user, @current_week)
			@total_cash = totals[0]
			@total_percent = totals[1]
		end
	end

	def create_week
		@current_portfolio = session[:current_portfolio_name] ? Portfolio.find_by_name(session[:current_portfolio_name]) : current_user.portfolios[0]

		if params[:week_type] == "empty" && @current_portfolio.portfolio_weeks.empty?
			@new_portfolio_week = @current_portfolio.portfolio_weeks.build(week_type: params[:week_type],
																		   date: Date.today.beginning_of_week(),
																		   free_cash: 0)
		elsif @current_portfolio.portfolio_weeks.last.date != nil
			@new_portfolio_week = @current_portfolio.portfolio_weeks.build(week_type: params[:week_type],
																		   date: @current_portfolio.portfolio_weeks.last.date + 1.week,
																		   free_cash: 0)
		else
			@new_portfolio_week = @current_portfolio.portfolio_weeks.build(week_type: params[:week_type],
																		   free_cash: 0)
		end
		@new_portfolio_week.save
		session[:current_week_id] = @new_portfolio_week.id

		@portfolio_traders = []
		
		# "reinvest" week traders
		if params[:week_type] == "reinvest"
			@new_portfolio_week.update_attributes(start_value: @current_portfolio.portfolio_weeks[-2].end_value)

			@current_portfolio.portfolio_weeks[-2].portfolio_traders.each do |portfolio_trader|
				new_week_portfolio_trader = @new_portfolio_week.portfolio_traders.build(trader_account: portfolio_trader.trader_account,
																						start_value: portfolio_trader.end_value)
				new_week_portfolio_trader.save
				@portfolio_traders.push new_week_portfolio_trader
			end

			# week traders for charts
			@portfolio_week_traders = current_portfolio_traders_for_week(@new_portfolio_week)
			@all_week_traders = all_portfolios_traders_for_week(@new_portfolio_week)
		end

		# total profit
		totals = total_profit_for(current_user, @new_portfolio_week)
		@total_cash = totals[0]
		@total_percent = totals[1]

		if @new_portfolio_week.date
			@is_history_chart_updated = true
			@history_profit = history_profit()
		end
	end

	def remove_week
		@current_portfolio = session[:current_portfolio_name] ? Portfolio.find_by_name(session[:current_portfolio_name]) : current_user.portfolios[0]

		@removed_week = session[:current_week_id] ? PortfolioWeek.find(session[:current_week_id]) : @current_portfolio.portfolio_weeks.last
		@is_history_chart_updated = true if @removed_week.date
		PortfolioWeek.find(@removed_week.id).destroy
		session.delete(:current_week_id)

		if @current_portfolio.portfolio_weeks.any?
			@current_week = @current_portfolio.portfolio_weeks.last
			session[:current_week_id] = @current_week.id

			# week traders for charts
			@portfolio_week_traders = current_portfolio_traders_for_week(@current_week)
			@all_week_traders = all_portfolios_traders_for_week(@current_week)

			@portfolio_traders = @current_week.portfolio_traders

			# total profit
			totals = total_profit_for(current_user, @current_week)
			@total_cash = totals[0]
			@total_percent = totals[1]

			# portfolio_rating
			rating_sum = 0
			weeks_count = 0
			@current_portfolio.portfolio_weeks.each do |week|
				 if (week.end_value && week.start_value && week.start_value != 0)
					rating_sum += (week.end_value / week.start_value - 1) * 100
					weeks_count += 1
				end
			end
			@current_portfolio.update_attributes(rating: (rating_sum / weeks_count).round(2)) if weeks_count != 0
		else
			@portfolio_traders = []
			@current_portfolio.update_attributes(rating: 0)
		end

		@history_profit = history_profit() if @is_history_chart_updated
	end

	def update_week_date
		@current_portfolio = session[:current_portfolio_name] ? Portfolio.find_by_name(session[:current_portfolio_name]) : current_user.portfolios[0]

		@current_week = session[:current_week_id] ? PortfolioWeek.find(session[:current_week_id]) : @current_portfolio.portfolio_weeks.last

		new_date = Date.strptime((params[:date].to_f / 1000).to_s, '%s').beginning_of_week()
		@is_date_updated = true
		@error_message = ""
		
		# if week with same date already exist
		@current_portfolio.portfolio_weeks.each do |portfolio_week|
			if portfolio_week.date && portfolio_week.date.strftime("%d.%m.%Y") == new_date.strftime("%d.%m.%Y")
				@is_date_updated = false
				@error_message = "This week already exists"
			end
		end

		# if new week is < then last week in portfolio
		previous_week_index = @current_portfolio.portfolio_weeks.index(@current_week) - 1 if @current_portfolio.portfolio_weeks.index(@current_week) > 0
		if previous_week_index && @is_date_updated && @current_portfolio.portfolio_weeks[previous_week_index].date && @current_portfolio.portfolio_weeks[previous_week_index].date > new_date
			@is_date_updated = false
			@error_message = "Date must be after the previous week in portfolio"
		end

		# update if week date is correct
		if @is_date_updated
			@current_week.update_attributes(date: new_date)

			# all portfolios week traders
			@all_week_traders = all_portfolios_traders_for_week(@current_week)

			# total profit
			totals = total_profit_for(current_user, @current_week)
			@total_cash = totals[0]
			@total_percent = totals[1]
		end

		@history_profit = history_profit() if @is_date_updated
	end

	def update_week_value
		@current_portfolio = session[:current_portfolio_name] ? Portfolio.find_by_name(session[:current_portfolio_name]) : current_user.portfolios[0]

		@current_week = session[:current_week_id] ? PortfolioWeek.find(session[:current_week_id]) : @current_portfolio.portfolio_weeks.last
		@current_week.update_attributes(start_value: params[:start_value]) if params[:start_value]
		@current_week.update_attributes(end_value: params[:end_value]) if params[:end_value]

		# total profit
		totals = total_profit_for(current_user, @current_week)
		@total_cash = totals[0]
		@total_percent = totals[1]

		# portfolio_rating
		rating_sum = 0
		weeks_count = 0
		@current_portfolio.portfolio_weeks.each do |week|
			 if (week.end_value && week.start_value && week.start_value != 0)
				rating_sum += (week.end_value / week.start_value - 1) * 100
				weeks_count += 1
			end
		end
		@current_portfolio.update_attributes(rating: (rating_sum / weeks_count).round(2)) if weeks_count != 0

		@history_profit = history_profit()
	end

	def update_week_free_cash
		@current_portfolio = session[:current_portfolio_name] ? Portfolio.find_by_name(session[:current_portfolio_name]) : current_user.portfolios[0]

		@current_week = session[:current_week_id] ? PortfolioWeek.find(session[:current_week_id]) : @current_portfolio.portfolio_weeks.last
		@current_week.update_attributes(free_cash: params[:free_cash]) if params[:free_cash]
	end

	def update_week_comment
		@current_portfolio = session[:current_portfolio_name] ? Portfolio.find_by_name(session[:current_portfolio_name]) : current_user.portfolios[0]

		@current_week = session[:current_week_id] ? PortfolioWeek.find(session[:current_week_id]) : @current_portfolio.portfolio_weeks.last
		@current_week.update_attributes(comment: params[:comment]) if params[:comment]
	end

	# methods with main table ===========================================================

	def update_table_cell
		@current_portfolio = session[:current_portfolio_name] ? Portfolio.find_by_name(session[:current_portfolio_name]) : current_user.portfolios[0]

		@current_week = session[:current_week_id] ? PortfolioWeek.find(session[:current_week_id]) : @current_portfolio.portfolio_weeks.last

		@portfolio_traders = @current_week.portfolio_traders

		@updated_portfolio_trader = @portfolio_traders.find_by_trader_account(params[:trader_account].to_i)
		@updated_portfolio_trader.update_attributes(start_value: params[:start_value]) if params[:start_value]
		@updated_portfolio_trader.update_attributes(end_value: params[:end_value]) if params[:end_value]

		if params[:start_value]
			# week traders for charts
			@portfolio_week_traders = current_portfolio_traders_for_week(@current_week)
			@all_week_traders = all_portfolios_traders_for_week(@current_week)
		end
	end

	def add_table_row
		@current_portfolio = session[:current_portfolio_name] ? Portfolio.find_by_name(session[:current_portfolio_name]) : current_user.portfolios[0]

		@current_week = session[:current_week_id] ? PortfolioWeek.find(session[:current_week_id]) : @current_portfolio.portfolio_weeks.last

		@portfolio_traders = @current_week.portfolio_traders
		
		portfolio_traders_accounts = []
		@portfolio_traders.each do |portfolio_trader|
			portfolio_traders_accounts.push portfolio_trader.trader_account
		end

		# add only unique traders
		unless portfolio_traders_accounts.include?(params[:trader_account].to_i)
			new_portfolio_trader = @current_week.portfolio_traders.build(trader_account: params[:trader_account].to_i, 
																		 start_value: "",
																		 end_value: "")
			new_portfolio_trader.save

			@is_table_row_added = true

			# week traders for charts
			@portfolio_week_traders = current_portfolio_traders_for_week(@current_week)
			@all_week_traders = all_portfolios_traders_for_week(@current_week)
		end
	end

	def remove_table_row
		@current_portfolio = session[:current_portfolio_name] ? Portfolio.find_by_name(session[:current_portfolio_name]) : current_user.portfolios[0]

		@current_week = session[:current_week_id] ? PortfolioWeek.find(session[:current_week_id]) : @current_portfolio.portfolio_weeks.last

		@portfolio_traders = @current_week.portfolio_traders

		@removed_portfolio_trader = @portfolio_traders.find_by_trader_account(params[:trader_account].to_i)
		@removed_portfolio_trader.destroy

		# week traders for charts
		@portfolio_week_traders = current_portfolio_traders_for_week(@current_week)
		@all_week_traders = all_portfolios_traders_for_week(@current_week)
	end

	# other methods =====================================================================

	def profile
		@user = current_user
	end

	# private methods ===================================================================

	private

		def signed_in_user
			unless signed_in?
				store_location
				# redirect_to signin_url, notice: "Please sign in"
				redirect_to root_path
			end
		end

		def unsigned_user
			if signed_in?
				redirect_to root_path, notice: "You already have an account"
			end
		end

		def correct_user
			@user = User.find(params[:id])
			redirect_to(root_path) unless current_user?(@user)
		end

		def admin_user
			redirect_to(root_path) unless current_user.admin?
		end
end
