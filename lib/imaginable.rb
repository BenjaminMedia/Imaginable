require 'rails'
require 'active_support/core_ext/class/attribute'

module Imaginable
  
  require 'imaginable/railtie'
  
  # The upload-server hostname
  mattr_accessor :upload_server
  #@@upload_server = 'http://127.0.0.1:3001'
  
  # The scale-server hostname
  mattr_accessor :scale_server
  #@@scale_server = 'http://127.0.0.1:3333'
  
  # Default way to setup Imaginable. Run rails generate imaginable:install to create
  # a fresh initializer with all configuration values.
  def self.setup
    yield self
  end
  
end
