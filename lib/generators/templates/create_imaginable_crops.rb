class CreateImaginableCrops < ActiveRecord::Migration
	def self.up
		create_table :imaginable_crops do |t|
			t.string  :uuid
			t.string  :crop # crop name, as defined in the Imaginable config
			t.float   :x    # x coord in %
			t.float   :y    # y coord in %
			t.float   :w    # width in %
		end
		add_index :imaginable_crops, [:uuid, :crop]
	end

	def self.down
		remove_index :imaginable_crops, [:uuid, :crop]
		drop_table :imaginable_crops
	end
end