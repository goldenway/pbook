namespace :db do
	desc "Fill database with sample data"
	task populate: :environment do
		admin = User.create!(name: 					"Igor",
			        		 email: 				"qwe@qwe.qwe",
					         password: 				"qweqwe",
					         password_confirmation: "qweqwe",
					         first_name: 			"igor",
					         second_name: 			"goldenway",
					         sex: 					"M",
					         date_of_birth: 		Date.new(1983,10,17),
					         country: 				"Ukr",
					         city: 					"Lviv",
					         start_inv_date: 		Date.today - 10.months,
					         social_vk: 			"vk.com/me",
					         social_fb: 			"facebook.com/me",
					         about_info: 			"some info about me...")
		admin.toggle!(:admin)
		
		2.times do |n|
			User.create!(name: 					"User_#{n+2}",
				         email: 				"email_#{n+2}@gmail.com", # Faker::Internet.email
				         password: 				"qweqwe",
				         password_confirmation: "qweqwe",
				         first_name: 			Faker::Name.first_name,
				         sex: 					["M", "W"].sample,
				         date_of_birth: 		Date.today.year - rand(40),
				         country: 				Faker::Address.country,
				         city: 					Faker::Address.city,
				         social_fb: 			Faker::Name.first_name,
				         about_info: 			"About info: lorem ipsum #{n+2}") # Faker::Lorem.sentence(1)
		end

		25.times do
			Trader.create!(brocker: 			["FX", "Panteon"].sample,
						   name: 				Faker::Name.first_name,
						   account: 			500000 + rand(120000),
						   registration_date: 	Date.today - rand(5).years - rand(11).months,
						   pamm2: 				[nil, nil, nil, (4 + rand(3)) * 10].sample,
						   tp: 					[1, 1, 1, 1, 2, 2, 4].sample,
						   min_value: 			[10, 50, 100, 100, 200, 1000].sample,
						   investor_percent: 	(4 + rand(4)) * 10)
		end

		User.all.each do |user|
			2.times do
				portfolio = user.portfolios.create!(
							name: 				Faker::Name.last_name)

				10.times do |index|
					portfolio_week = portfolio.portfolio_weeks.create!(
							week_type: 			"empty",
							date: 				(Date.today - 7.months + index.weeks).beginning_of_week(),
							start_value: 		1000,
							end_value: 			(900 + 10 * rand(30)),
							free_cash: 			rand(10) * 50,
							comment: 			Faker::Lorem.sentence(5))

					(5 + rand(3)).times do
						trader = Trader.all.sample
						portfolio_week.portfolio_traders.create!(
							trader_account: 	trader.account,
							start_value: 		100,
							end_value: 			(90 + rand(23) + rand).round(2))
					end
				end
			end
		end
	end
end

