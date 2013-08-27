require 'imaginable/image'
require 'imaginable/crop'

module Imaginable
  module Model
    def has_imagination(column, options = {})
      extend ClassMethods
      belongs_to column, :class_name => 'Imaginable::Image'

      define_method "has_#{column}?" do
        !self.send("#{column}_id").nil?
      end
    end
    
    module ClassMethods
      def validates_imagination(column, opts = {})
        validate_presence_of column, *opts
      end
    end
  end
end