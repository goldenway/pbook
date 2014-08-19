module UsersHelper
	# returns the Gravatar  (http://gravatar.com/) for the given user
	def gravatar_for(user, options = { size: 50 })
		gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
		size = options[:size]
		gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
		image_tag(gravatar_url, alt: user.name, class: "gravatar")
	end

	def total_profit_for(user, week)
		total_start_value = 0
		total_end_value = 0

		user.portfolios.each do |portfolio|
			portfolio.portfolio_weeks.each do |portfolio_week|
				if week.date && portfolio_week.date && portfolio_week.date.strftime("%d.%m.%Y") == week.date.strftime("%d.%m.%Y") && portfolio_week.start_value && portfolio_week.end_value
					total_start_value += portfolio_week.start_value
					total_end_value += portfolio_week.end_value
				end
			end
		end
		
		total_cash = total_end_value - total_start_value
		total_percent = (total_start_value != 0) ? (total_end_value / total_start_value - 1) * 100 : 0
		return [total_cash, total_percent]
	end

	def all_portfolios_traders_for_week (week)
		all_week_traders = []
		current_user.portfolios.each do |portfolio|
			portfolio.portfolio_weeks.each do |portfolio_week|
				if portfolio_week.date && week.date && portfolio_week.date.strftime("%d.%m.%Y") == week.date.strftime("%d.%m.%Y")
					# construct array of traders
					portfolio_week.portfolio_traders.each do |portfolio_trader|
						if all_week_traders.empty?
							item = {
								trader_account: portfolio_trader.trader_account,
								trader_name: Trader.find_by_account(portfolio_trader.trader_account).name,
								trader_value: portfolio_trader.start_value ? portfolio_trader.start_value : 0
							}
							all_week_traders.push item
						else
							is_new_trader = false
							all_week_traders.each do |tr|
								if tr.has_value?(portfolio_trader.trader_account)
									tr[:trader_value] += portfolio_trader.start_value if portfolio_trader.start_value
									is_new_trader = false
									break
								end
								is_new_trader = true
							end
							if is_new_trader
								item = {
									trader_account: portfolio_trader.trader_account,
									trader_name: Trader.find_by_account(portfolio_trader.trader_account).name,
									trader_value: portfolio_trader.start_value ? portfolio_trader.start_value : 0
								}
								all_week_traders.push item
							end
						end
					end
				end
			end
		end
		all_week_traders.sort_by! { |tr| tr[:trader_value] }
		all_week_traders.reverse!
	end

	def current_portfolio_traders_for_week (week)
		portfolio_week_traders = []
		week.portfolio_traders.each do |portfolio_trader|
			item = {
				trader_account: portfolio_trader.trader_account,
				trader_name: Trader.find_by_account(portfolio_trader.trader_account).name,
				trader_value: portfolio_trader.start_value ? portfolio_trader.start_value : 0
			}
			portfolio_week_traders.push item
		end
		portfolio_week_traders.sort_by! { |tr| tr[:trader_value] }
		portfolio_week_traders.reverse!
	end

	def history_profit
		history_profit = []
		current_user.portfolios.each do |portfolio|
			portfolio.portfolio_weeks.each do |portfolio_week|
				if portfolio_week.date
					item = {
						portfolio_name: portfolio.name,
						week_date: portfolio_week.date.strftime("%d.%m.%Y"),
						week_profit_percent: (portfolio_week.start_value && portfolio_week.end_value && portfolio_week.start_value != 0) ? (portfolio_week.end_value - portfolio_week.start_value) / portfolio_week.start_value * 100 : 0,
						week_profit_cash: (portfolio_week.start_value && portfolio_week.end_value) ? (portfolio_week.end_value - portfolio_week.start_value) : 0
					}
					history_profit.push item
				end
			end
		end
		history_profit
	end
end


