# encoding: utf-8

require 'rails/generators/active_record'

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
    include Rails::Generators::Migration
    def self.next_migration_number(*args)
      ActiveRecord::Generators::Base.next_migration_number(*args)
    end

    desc "Copies the necessary js-files to public/javascripts/, the necessary css-files and images to public/stylesheets and a config initializer to config/initializers/imaginable.rb"

    source_root File.expand_path('../../../templates', __FILE__)

    def copy_files
      copy_file   'imaginable.rb',    'config/initializers/imaginable.rb'
      directory   'images',           'public/images'
      directory   'javascripts',      'public/javascripts'
      directory   'stylesheets',      'public/stylesheets'
      directory   'controllers',      'app/controllers/imaginable'

      migration_template 'create_imaginable_images.rb', 'db/migrate/create_imaginable_images.rb'
      migration_template 'create_imaginable_crops.rb', 'db/migrate/create_imaginable_crops.rb'
    end
  end
end