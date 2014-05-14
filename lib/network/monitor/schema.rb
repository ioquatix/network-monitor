
module Network
	module Monitor
		def self.migrate_database!
			ActiveRecord::Schema.define(:version => 1) do
				create_table :interfaces do |t|
					t.string :host, :null => false
					t.integer :ifIndex, :null => false

					t.integer :ifSpeed, :null => false

					t.integer :ifInOctets, :null => false
					t.integer :ifOutOctets, :null => false

					t.integer :ifInErrors, :null => false
					t.integer :ifOutErrors, :null => false

					t.datetime :created_at
	  
					t.index :host
					t.index :ifIndex
					t.index :created_at
				end
			end
		end
	end
end
