class CreatePortfolioWeeks < ActiveRecord::Migration
	def change
		create_table :portfolio_weeks do |t|
			t.integer :portfolio_id
			t.float :profit

			t.timestamps
		end
	end
end
