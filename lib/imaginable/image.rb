module Imaginable
  
  class Image
    
    attr_accessor :uuid, :token
    
    def initialize(uuid, token, version)
      @uuid = uuid
      @token = token
      @version = version
    end
    
    def url(options = {})
      options[:width] ||= 0
      options[:format] ||= 'original'
      
      height = options.has_key?(:height) ? "-#{options[:height]}" : ""
      
      "#{Imaginable.scale_server}/image/#{@uuid}-#{@version}-#{options[:format]}-#{options[:width]}#{height}.jpg"
    end
    
  end
  
end