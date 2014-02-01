namespace :db do
	desc "Fill database with sample data"
	task populate: :environment do
		admin = User.create!(name: 				"Igor",
			        		 email: 			"qwe@qwe.qwe",
					         password: 			"qweqwe",
					         password_confirmation: "qweqwe")
		admin.toggle!(:admin)
		
		24.times do |n|
			User.create!(name: 					"User_#{n+2}",
				         email: 				"email_#{n+2}@gmail.com", # Faker::Internet.email
				         password: 				"qweqwe",
				         password_confirmation: "qweqwe",
				         first_name: 			Faker::Name.first_name,
				         sex: 					["M", "W"].sample,
				         date_of_birth: 		Time.now.year - rand(40),
				         country: 				Faker::Address.country,
				         city: 					Faker::Address.city,
				         social_fb: 			Faker::Name.first_name,
				         about_info: 			"Lorem#{n+2}") # Faker::Lorem.sentence(1)
		end

		12.times do
			Trader.create!(brocker: 			["FX", "Panteon"].sample,
						   name: 				Faker::Name.first_name,
						   account: 			500000 + rand(65000),
						   registration_date: 	Time.now.year - rand(5),
						   pamm2: 				[nil, (4 + rand(3)) * 10].sample,
						   tp: 					[1, 2, 4].sample,
						   min_value: 			[10, 50, 100, 200].sample,
						   investor_percent: 	(4 + rand(4)) * 10)
		end

		3.times do
			User.all.each do |user|
				portfolio = user.portfolios.create!(
							name: 				Faker::Name.last_name,
							rating: 			(-1 + rand(5) + rand).round(2),
							comment: 			Faker::Lorem.sentence(5))

				3.times do
					portfolio_week = portfolio.portfolio_weeks.create!(
							profit: 			(-1 + rand(5) + rand).round(2))

					5.times do
						trader = Trader.all.sample
						portfolio_week.portfolio_traders.create!(
							trader_account: 	trader.account,
							start_value: 		100,
							end_value: 			110 + rand(9))
					end
				end
			end
		end
	end
end

