require 'rails'

module Imaginable
  
  class Railtie < Rails::Railtie
    
    initializer 'imaginable' do |app|
      
      ActiveSupport.on_load(:active_record) do
        require 'imaginable/model'
        require 'imaginable/schema'
        ::ActiveRecord::Base.send(:extend, Imaginable::Model)
        ::ActiveRecord::ConnectionAdapters::Table.send(:include, Imaginable::Schema)
        ::ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, Imaginable::Schema)
      end
      
      ActiveSupport.on_load(:action_view) do
        require 'imaginable/form_builder'
        ::ActionView::Helpers::FormBuilder.send(:include, Imaginable::FormBuilder)
        ::ActionView::Helpers::InstanceTag.send(:include, Imaginable::InstanceTag)
      end
      
    end
    
  end
  
end