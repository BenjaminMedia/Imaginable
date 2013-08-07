class CreateImaginableCrops < ActiveRecord::Migration
	def self.up
		create_table :imaginable_crops do |t|
			t.integer :image_id # belongs_to image
			t.string  :crop # crop name, as defined in the Imaginable config
			t.integer :x    # x coord in px
			t.integer :y    # y coord in px
			t.integer :w    # width in px
		end
		add_index :imaginable_crops, [:id, :crop]
	end

	def self.down
		remove_index :imaginable_crops, [:id, :crop]
		drop_table :imaginable_crops
	end
end