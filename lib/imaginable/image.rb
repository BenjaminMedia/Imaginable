module Imaginable
  
  class Image
    
    attr_accessor :uuid, :token
    
    def initialize(uuid, token)
      @uuid = uuid
      @token = token
    end
    
    def url(options = {})
      options[:width] ||= 100
      
      "#{Imaginable.scale_server}/image/#{@uuid}-0-original-#{options[:width]}.jpg"
    end
    
  end
  
end