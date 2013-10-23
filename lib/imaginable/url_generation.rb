module Imaginable
  module UrlGeneration
    def host
      s = (uuid[0].ord % 6) + 1
      "s#{s}.#{Imaginable.app_host}"
    end

    def url(options = {})
      format         = options[:format] || :jpg
      quality_string = "q=#{options[:q] || Imaginable.default_jpeg_quality}" if format == :jpg
      crop_string    = get_crop_string(options)
      scale_string   = get_scale_string(options)

      opts = [crop_string, scale_string, quality_string].compact.join('&')
      urlopts = opts.empty? ? "" : "?#{opts}"
      "http://#{self.host}/#{self.uuid}.#{format}#{urlopts}"
    end

    def bound_crop_to_image(x0, y0, max_width, ratio)
      # Make sure we're doing floating-point math:
      w, h = self.width.to_f, self.height.to_f
      x0, y0, max_width, ratio = x0.to_f, y0.to_f, max_width.to_f, ratio.to_f

      # Bound width to self
      max_width = w - x0 if x0 + max_width > w

      # Bound height and width within ratio
      max_height = max_width * ratio
      if y0 + max_height > h
        max_height = h - y0
        max_width = max_height / ratio
      end
      return max_width, max_height
    end

    def get_crop_string(options = {})
      crop = options[:crop]
      crop = crop.intern if crop.is_a?(String)
      if crop.is_a?(Hash)
        x0 = crop[:x0] || 0
        y0 = crop[:y0] || 0
        x1 = crop[:x1] || 100
        y1 = crop[:y1] || 100
        mode = crop[:mode] || 'crop'
        crop_string = "crop=#{x0},#{y0},#{x1},#{y1}&mode=#{mode}"
      elsif crop.is_a?(Symbol) && crop != :none
        named_ratio = Imaginable.named_ratios[crop]
        raise "Undefined crop type #{crop.inspect}." unless named_ratio
        crop_info = get_or_initialize_named_crop(crop)
        if named_ratio && named_ratio != 0
          # Calculate crop bounds from ratio
          crop_info.x ||= 0.0
          crop_info.y ||= 0.0
          crop_info.w ||= width
          x0, y0 = crop_info.x, crop_info.y
          w, h = bound_crop_to_image(x0, y0, crop_info.w, named_ratio)
          x1, y1 = x0 + w, y0 + h
          crop_string = "crop=#{x0.to_i}px,#{y0.to_i}px,#{x1.to_i}px,#{y1.to_i}px&mode=max"
        end
      elsif crop == :none
        return "mode=max"
      elsif crop
        raise "Undefined crop type #{crop.inspect}."
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