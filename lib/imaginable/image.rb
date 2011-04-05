module Imaginable
  
  class Image
    
    attr_accessor :uuid, :token
    
    def initialize(uuid, token, version)
      @uuid = uuid
      @token = token
      @version = version
    end
    
    def url(options = {})
      options[:width] ||= 100
      
      height = options.has_key?(:height) ? "-#{options[:height]}" : ""
      format = options.has_key?(:format) ? options[:format] : "original"
      
      "#{Imaginable.scale_server}/image/#{@uuid}-#{@version}-#{format}-#{options[:width]}#{height}.jpg"
    end
    
  end
  
end