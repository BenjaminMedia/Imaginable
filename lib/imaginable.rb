require 'rails'
require 'active_support/core_ext/class/attribute'
require 'cdnconnect_api'

module Imaginable
  
  require 'imaginable/railtie'

  # CDN Connect app host.
  mattr_accessor :app_host 

  # CDN Connect API key.
  mattr_accessor :api_key

  # A hash of crop ratios used in this app's design, specified as height/width.
  # { :name => ratio, ... }
  mattr_accessor :named_ratios

  # The default format for cropped/scaled images.
  mattr_accessor :default_format

  # The default JPEG quality
  mattr_accessor :default_jpeg_quality
  
  # Default way to setup Imaginable. Run rails generate imaginable:install to create
  # a fresh initializer with all configuration values.
  def self.setup
    yield self
  end
  
  def self.upload(*args)
    Imaginable::Image.upload(*args)
  end

  def self.cdn
    @cdn ||= CDNConnect::APIClient.new(:app_host => self.app_host, :api_key => self.api_key)
  end

  def self.generate_upload_url
    cdn.get_upload_url('/').results['upload_url']
  end
end
