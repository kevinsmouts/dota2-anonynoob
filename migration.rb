require 'active_record'
require 'pg'

ActiveRecord::Base.establish_connection(
  adapter:  'postgresql',
  host:     'localhost',
  database: 'anonynoob',
  username: 'postgres'
)

class CreateMatchesTable < ActiveRecord::Migration
	def create

		create_table :matches do |t|

	    	#match id
	      	t.integer :match_id, limit: 8

	    	#event time
	    	t.integer :anonymous_radiant
	    	t.integer :anonymous_dire
	    	t.string :victory

	    end

	end
end

CreateMatchesTable.migrate("create")