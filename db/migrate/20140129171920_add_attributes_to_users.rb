class AddAttributesToUsers < ActiveRecord::Migration
	def change
		add_column :users, :first_name, 	:string
		add_column :users, :second_name,	:string
		add_column :users, :sex, 			:string
		add_column :users, :date_of_birth, 	:datetime
		add_column :users, :country, 		:string
		add_column :users, :city, 			:string
		add_column :users, :start_inv_date,	:datetime
		add_column :users, :social_vk, 		:string
		add_column :users, :social_fb, 		:string
		add_column :users, :about_info, 	:string
	end
end
