require 'imaginable/image'
require 'imaginable/crop'

module Imaginable
  module Model
    def has_imagination(column, options = {})
      extend ClassMethods
      belongs_to column, :class_name => 'Imaginable::Image'
      attr_accessible "#{column}_attributes"

      define_method "has_#{column}?" do
        !self.send("#{column}_id").nil?
      end

      define_method "#{column}_attributes=" do |attributes|
        img = Imaginable::Image.where(:uuid => attributes[:uuid]).first || Imaginable::Image.create do |i|
          i.uuid = attributes[:uuid]
        end
        raise "Mismatched image token (probable request forgery)." unless img.authorize_token?(attributes[:token])
        img.update_attributes(attributes)
        self.send("#{column}=", img)
      end
    end
    
    module ClassMethods
      def validates_imagination(column, opts = {})
        validate_presence_of column, *opts
      end
    end
  end
end