class CreateImaginableImages < ActiveRecord::Migration
	def self.up
		create_table :imaginable_images do |t|
			t.string  :uuid
			t.string  :token  # for authentication purposes
			t.integer :width  # width in px
			t.integer :height # height in px
		end
		add_index :imaginable_images, :uuid, :unique => true
	end

	def self.down
		remove_index :imaginable_images, :uuid
		drop_table :imaginable_images
	end
end