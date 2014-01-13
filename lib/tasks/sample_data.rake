namespace :db do
	desc "Fill database with sample data"
	task populate: :environment do
		admin = User.create!(name: "Igor",
			        		 email: "qwe@qwe.qwe",
					         password: "qweqwe",
					         password_confirmation: "qweqwe")
		admin.toggle!(:admin)
		
		99.times do |n|
			name = "User-#{n}" # Faker::Name.name
			email = "qwe-#{n+1}@qwe.qwe"
			password = "qweqwe"
			User.create!(name: name,
				         email: email,
				         password: password,
				         password_confirmation: password)
		end
	end
end
