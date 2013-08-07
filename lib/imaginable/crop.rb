module Imaginable
	class Crop < ActiveRecord::Base
		set_table_name 'imaginable_crops'
		belongs_to :image, :class_name => 'Imaginable::Image', :foreign_key => :image_id, :dependent => true
	end
end