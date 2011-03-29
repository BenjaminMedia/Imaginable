# encoding: utf-8

module Imaginable
  # Copies imaginable.js, plupload.flash.swf and plupload.full.min.js to public/javascripts/ and a config initializer
  # to config/initializers/imaginable.rb.
  #
  # @example
  #   $ rails generate imaginable:install
  #
  # @todo Revisit in Rails 3.1 where public assets are treated differently
  class InstallGenerator < Rails::Generators::Base
    desc "Copies imaginable.js, plupload.flash.swf and plupload.full.min.js to public/javascripts/ and a config initializer to config/initializers/imaginable.rb"

    source_root File.expand_path('../../../templates', __FILE__)

    def copy_files
      copy_file        'imaginable.rb',          'config/initializers/imaginable.rb'
      copy_file        'imaginable.js',          'public/javascripts/imaginable.js'
      copy_file        'plupload.full.min.js',   'public/javascripts/plupload.full.min.js'
      copy_file        'plupload.flash.swf',     'public/javascripts/plupload.flash.swf'
    end
  end
end