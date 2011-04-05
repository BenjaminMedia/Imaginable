module Imaginable
  module Schema
   
   def imaginable(column, options = {})
     column "#{column}_uuid", :string, options
     column "#{column}_token", :string, options
     column "#{column}_version", :string, options
   end
   
  end
end