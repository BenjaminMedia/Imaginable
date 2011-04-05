# encoding: utf-8

module Imaginable
  # Copies the necessary js-files to public/javascripts/,
  # the necessary css-files and images to public/stylesheets
  # and a config initializer to config/initializers/imaginable.rb
  #
  # @example
  #   $ rails generate imaginable:install
  #
  # @todo Revisit in Rails 3.1 where public assets are treated differently
  class InstallGenerator < Rails::Generators::Base
    desc "Copies the necessary js-files to public/javascripts/, the necessary css-files and images to public/stylesheets and a config initializer to config/initializers/imaginable.rb"

    source_root File.expand_path('../../../templates', __FILE__)

    def copy_files
      copy_file   'imaginable.rb',                  'config/initializers/imaginable.rb'
      copy_file   'imaginable.js',                  'public/javascripts/imaginable.js'
      copy_file   'plupload.full.min.js',           'public/javascripts/plupload.full.min.js'
      copy_file   'plupload.flash.swf',             'public/javascripts/plupload.flash.swf'
      copy_file   'jquery.fancybox-1.3.4.pack.js',  'public/javascripts/jquery.fancybox-1.3.4.pack.js'
      copy_file   'jquery.imgareaselect.pack.js',   'public/javascripts/jquery.imgareaselect.pack.js'
      directory   'fancybox',                       'public/stylesheets/fancybox'
      directory   'imgareaselect',                  'public/stylesheets/imgareaselect'
    end
  end
end