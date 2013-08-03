require 'uuidtools'

module Imaginable
  class Image
    attr_accessor :uuid, :token
    
    def initialize(uuid, token)
      @uuid = uuid
      @token = token
    end

    class UploadError < RuntimeError; end

    # Server-side uploading. Prefer client-side when possible!
    def self.upload(path, options = {})
      uuid = self.generate_uuid
      token = self.generate_token(uuid)
      image = self.new(uuid, token)
      options[:destination_path] = '/'
      options[:source_file_path] = path
      options[:async] = false # TODO!
      response = Imaginable.cdn.upload(options)
      if response.files.any? && response.files.first['upload_success']
        return image
      else
        if response.files.any?
          message = response.files.first['msgs'].map{|msg| msg['text']}.join("\n")
        else
          message = response.msgs.join("\n")
        end
        raise UploadError, message
      end
    end

    def get_named_crops
      ImaginableCrop.for_uuid(@uuid)
    end

    def get_named_crop(crop)
      ImaginableCrop.get(@uuid, crop)
    end

    def set_named_crop(crop, x, y, w) # x,y,w in %
      crop = ImaginableCrop.get(@uuid, crop)
      crop.x, crop.y, crop.w = x, y, w
      crop.save
    end
    
    def url(options = {})
      format      = options[:format] || :jpg
      named_crop  = options[:named_crop]
      custom_crop = options[:crop]

      if custom_crop
        x0 = custom_crop[:x0] || 0
        y0 = custom_crop[:y0] || 0
        x1 = custom_crop[:x1] || 100
        y1 = custom_crop[:y1] || 100
        mode = custom_crop[:mode] || 'max'
        crop_string = "crop=#{x0},#{y0},#{x1},#{y1}&mode=#{mode}"
      elsif named_crop && named_crop != :none
        named_ratio = Imaginable.named_ratios[named_crop]
        crop = self.get_named_crop(named_crop)
        if named_ratio && named_ratio != 0
          # Calculate crop bounds from ratio
          crop.x ||= 0.0
          crop.y ||= 0.0
          crop.w ||= 100.0

          x0, y0, x1 = crop.x, crop.y, crop.x + crop.w
          y1 = crop.y + crop.w * named_ratio
          crop_string = "crop=#{x0.round(2)},#{y0.round(2)},#{x1.round(2)},#{y1.round(2)}&mode=max"
        end
      end

      scale_string = [
          ("width=#{options[:width]}" if options[:width]),
          ("height=#{options[:height]}" if options[:height])
      ].compact.reject(&:empty?).join('&')
      opts = [crop_string, scale_string].compact.reject(&:empty?).join('&')
      urlopts = !opts.empty? ? "?#{opts}" : ""
      
      "http://#{Imaginable.app_host}/#{@uuid}.#{format}#{urlopts}"
    end

    private
    def self.generate_uuid
      UUIDTools::UUID.random_create.to_s.gsub(/\-/, '')
    end

    def self.generate_token(uuid)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), uuid, rand.to_s).to_s
    end
  end
end