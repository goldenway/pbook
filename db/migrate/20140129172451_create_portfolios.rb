class CreatePortfolios < ActiveRecord::Migration
	def change
		create_table :portfolios do |t|
			t.integer :user_id
			t.string :name
			t.float :rating

			t.timestamps
		end
	end
end
