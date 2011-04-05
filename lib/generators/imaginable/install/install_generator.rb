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
      copy_file   'imaginable.rb',    'config/initializers/imaginable.rb'
      directory   'images',           'public/images'
      directory   'javascripts',      'public/javascripts'
      directory   'stylesheets',      'public/stylesheets'
    end
  end
end