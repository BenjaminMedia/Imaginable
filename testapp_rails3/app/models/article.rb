class Article < ActiveRecord::Base
	has_imagination :photo
	scope :published, :conditions => "published_at >= date('now')"
end
