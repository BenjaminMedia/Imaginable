class ImaginableCrop < ActiveRecord::Base
	scope :for_uuid, proc { |uuid| where(:uuid => uuid) }
	scope :for_crop, proc { |crop| where(:crop => crop) }

	def self.get(uuid, crop)
		self.for_uuid(uuid).for_crop(crop).first || self.new(:uuid => uuid, :crop => crop)
	end
end