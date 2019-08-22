require 'rails/generators/active_record'
require 'rails/generators/migration'

module PolicyManager
  module Generators
    class PaperclipGenerator < Rails::Generators::Base
      
      #self.class.include Rails::Generators::Migration

      #desc "Installs mygem and generates the necessary migrations"
      #source_root File.expand_path("../templates", __FILE__)

      #def create_migrations
      #  migration_template 'migrations/paperclip_fields.rb', "db/migrate/add_foo_to_bar.rb"
      #end

    end
  end
end