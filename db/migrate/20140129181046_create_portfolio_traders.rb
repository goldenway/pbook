class CreatePortfolioTraders < ActiveRecord::Migration
	def change
		create_table :portfolio_traders do |t|
			t.integer :portfolio_week_id
			t.integer :trader_account
			t.float :start_value
			t.float :end_value

			t.timestamps
		end
	end
end
