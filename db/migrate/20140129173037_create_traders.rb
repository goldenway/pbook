class CreateTraders < ActiveRecord::Migration
    def change
        create_table :traders do |t|
            t.string :brocker
            t.string :name
            t.integer :account
            t.date :registration_date
            t.integer :pamm2
            t.integer :tp
            t.integer :min_value
            t.integer :investor_percent

            t.timestamps
        end
    end
end
