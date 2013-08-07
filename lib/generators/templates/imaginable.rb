Imaginable.setup do |config|
  config.app_host = ENV['CDN_CONNECT_APP_HOST']
  config.api_key  = ENV['CDN_CONNECT_API_KEY']

  config.default_format       = :jpg
  config.default_jpeg_quality = 85

  # name => height/width
  # Example: { :widescreen => 9.0/16.0 }
  config.named_ratios = {
  	:original => 0,
  	:square   => 1.0,
  	:tv       => 9.0/13.0,
  	:wide     => 12.0/29.0,
  	:portrait => 3.0/2.0,
  	:wide169  => 9.0/16.0,
  }
end