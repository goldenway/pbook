class CreatePortfolioWeeks < ActiveRecord::Migration
	def change
		create_table :portfolio_weeks do |t|
			t.integer :portfolio_id
			t.string :week_type
			t.date :date
			t.float :start_value
			t.float :end_value
			t.float :free_cash
			t.string :comment
			
			t.timestamps
		end
	end
end
