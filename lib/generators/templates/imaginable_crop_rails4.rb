class ImaginableCrop < ActiveRecord::Base
	scope :for_uuid, ->(uuid) { where(:uuid => uuid) }
	scope :for_crop, ->(crop) { where(:crop => crop) }

	def self.get(uuid, crop)
		self.for_uuid(uuid).for_crop(crop).first_or_initialize
	end
end