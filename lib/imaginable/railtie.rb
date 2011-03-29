module Imaginable
  
  require 'imaginable'
  require 'imaginable/form_builder'
  require 'imaginable/model'
  require 'imaginable/schema'
  require 'rails'
  require 'formtastic'
  
  class Railtie < Rails::Railtie
    config.to_prepare do
      ActiveRecord::Base.send(:extend, Imaginable::Model)
      ActionView::Helpers::FormBuilder.send(:include, Imaginable::FormBuilder)
      ActionView::Helpers::InstanceTag.send(:include, Imaginable::InstanceTag)
      ActiveRecord::ConnectionAdapters::Table.send(:include, Imaginable::Schema)
      ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, Imaginable::Schema)
    end
  end
  
end