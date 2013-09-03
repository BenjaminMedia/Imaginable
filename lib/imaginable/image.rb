require 'uuidtools'
require 'imaginable/url_generation'
require 'imaginable/uploading'

module Imaginable
  class Image < ActiveRecord::Base
    include Imaginable::UrlGeneration
    include Imaginable::Uploading
    set_table_name 'imaginable_images'
    has_many :crops, :class_name => 'Imaginable::Crop', :foreign_key => :image_id
    attr_accessible :width, :height
    after_initialize :set_uuid_and_token

    def to_url
      uuid
    end

    def get_or_initialize_named_crop(crop)
      crops.where(:crop => crop).first || Imaginable::Crop.new(:crop => crop, :image => self)
    end

    def authorize_token?(token)
      return self.class.check_token(uuid, token)
    end

    private
    def self.generate_uuid
      UUIDTools::UUID.random_create.to_s.gsub(/\-/, '')
    end

    def self.generate_token(uuid)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), uuid, Imaginable.secret).to_s
    end

    def self.check_token(uuid, token)
      correct_token = generate_token(uuid)
      return token == correct_token
    end

    def set_uuid_and_token
      self.uuid ||= self.class.generate_uuid
      self.token ||= self.class.generate_token(self.uuid)
      self.uuid
    end
  end
end