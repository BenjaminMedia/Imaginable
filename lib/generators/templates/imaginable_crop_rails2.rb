class ImaginableCrop < ActiveRecord::Base
	named_scope :for_uuid, lambda { |uuid| {:conditions => {:uuid => uuid}} }
	named_scope :for_crop, lambda { |crop| {:conditions => {:crop => crop}} }

	def self.get(uuid, crop)
		self.for_uuid(uuid).for_crop(crop).first || self.new(:uuid => uuid, :crop => crop)
	end
end