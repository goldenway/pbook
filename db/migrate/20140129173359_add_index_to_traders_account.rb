class AddIndexToTradersAccount < ActiveRecord::Migration
	def change
		add_index :traders, :account, unique: true
	end
end
