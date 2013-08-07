require 'uuidtools'

module Imaginable
  class Image < ActiveRecord::Base
    set_table_name 'imaginable_images'
    validates_uniqueness_of :uuid
    has_many :crops, :class_name => 'Imaginable::Crop', :foreign_key => :image_id

    # TODO: Consider if this will work in Rails 2?
    attr_accessible :width, :height

    class UploadError < RuntimeError; end

    # Server-side uploading. Prefer client-side when possible!
    def self.upload(path, options = {})
      image = self.new
      image.uuid  = self.generate_uuid
      image.token = self.generate_token(image.uuid)
      options[:destination_path] = '/'
      options[:source_file_path] = path
      options[:async] = false # TODO: Webhook support
      ext = File.extname(path)
      options[:destination_file_name] = "#{image.uuid}#{ext}"
      response = Imaginable.cdn.upload(options)
      if response.files && response.files.any? && response.files.first['upload_success']
        # TODO: Can we find the image dimensions from the response?
        image.save!
        return image
      else
        if response.files && response.files.any?
          message = response.files.first['msgs'].map{|msg| msg['text']}.join("\n")
        else
          message = response.msgs.join("\n")
        end
        raise UploadError, message
      end
    end
    
    def url(options = {})
      format         = options[:format] || :jpg
      quality_string = "q=#{options[:q] || Imaginable.default_jpeg_quality}" if format == :jpg
      crop_string    = get_crop_string(options)
      scale_string   = get_scale_string(options)
      
      opts = [crop_string, scale_string, quality_string].compact.join('&')
      urlopts = opts.empty? ? "" : "?#{opts}"
      "http://#{Imaginable.app_host}/#{self.uuid}.#{format}#{urlopts}"
    end

    private
    def self.generate_uuid
      UUIDTools::UUID.random_create.to_s.gsub(/\-/, '')
    end

    def self.generate_token(uuid)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), uuid, rand.to_s).to_s
    end

    rails_version = Rails.version.split('.').map(&:to_i)
    if rails_version[0] >= 3
      def get_or_initialize_named_crop(crop)
        crops.where(:crop => crop).first || Imaginable::Crop.new(:crop => crop, :image => self)
      end
    else
      def get_or_initialize_named_crop(crop)
        Imaginable::Crop.find(:conditions => {:image => self, :crop => crop}).first || Imaginable::Crop.new(:crop => crop, :image => self)
      end
    end

    def get_crop_string(options = {})
      crop = options[:crop]
      crop = crop.intern if crop.is_a?(String)
      if crop.is_a?(Hash)
        x0 = crop[:x0] || 0
        y0 = crop[:y0] || 0
        x1 = crop[:x1] || 100
        y1 = crop[:y1] || 100
        mode = crop[:mode] || 'max'
        crop_string = "crop=#{x0},#{y0},#{x1},#{y1}&mode=#{mode}"
      elsif crop.is_a?(Symbol) && crop != :none
        named_ratio = Imaginable.named_ratios[crop]
        crop_info = get_or_initialize_named_crop(crop)
        if named_ratio && named_ratio != 0
          # Calculate crop bounds from ratio
          crop_info.x ||= 0.0
          crop_info.y ||= 0.0
          crop_info.w ||= 100.0
          x0, y0, x1 = crop_info.x, crop_info.y, crop_info.x + crop_info.w
          y1 = crop_info.y + crop_info.w * named_ratio
          crop_string = "crop=#{x0.to_i}px,#{y0.to_i}px,#{x1.to_i}px,#{y1.to_i}px&mode=max"
        end
      end
      crop_string
    end

    def get_scale_string(options = {})
      str = [
          ("width=#{options[:width]}" if options[:width]),
          ("height=#{options[:height]}" if options[:height])
      ].compact.join('&')
      str.empty? ? nil : str
    end
  end
end