require 'imaginable/image'

module Imaginable
  
  module Model
    
    def has_imagination(column, options = {})
      extend ClassMethods
      include InstanceMethods
      
      class_attribute :_imaginable_settings
      
      self._imaginable_settings = { :column => column }
      self._imaginable_settings.update(options) if options.is_a?(Hash)
      
      define_method "has_#{column}?" do
        uuid = self["#{column}_uuid"]
        token = self["#{column}_token"]
        
        return false unless uuid && token
        
        !uuid.empty? && !token.empty?
      end
      
      define_method column do
        uuid = self["#{column}_uuid"]
        token = self["#{column}_token"]
        Image.new(uuid, token)
      end

      define_method "#{column}=" do |image|
        raise ArgumentError, "Expected instance of Imaginable::Image." unless image.is_a?(Imaginable::Image)
        self["#{column}_uuid"] = image.uuid
        self["#{column}_token"] = image.token
        image
      end
    end
    
    module ClassMethods
      
      def validates_imagination
        validate :validate_imagination
      end
      
    end
    
    module InstanceMethods
      
      private
      
        def validate_imagination
          settings = self.class._imaginable_settings
          column = settings[:column]
          
          errors.add(column, I18n.translate('imaginable.errors.must_be_set')) unless
            attribute_present?("#{column}_uuid") && attribute_present?("#{column}_token")
        end
      
    end
    
  end
  
end