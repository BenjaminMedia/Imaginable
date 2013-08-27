module Imaginable
  module Schema
   def imaginable(column, options = {})
     column "#{column}_id", :integer, options
   end
  end
end