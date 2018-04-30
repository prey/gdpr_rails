require 'test_helper'
require 'ostruct'

module PolicyManager
  class ExporterTest < ActiveSupport::TestCase
    
    def setup
      PolicyManager::Term.create(description: "el", rule: "age")

      @config = PolicyManager::Config.setup do |c|
        c.add_rule({name: "age", validates_on: [:create, :update], 
                    if: ->(o){ o.enabled_for_validation } })
        c.exporter = { 
          path: Rails.root + "tmp/export", 
          resource: User ,
          index_template: '<h1>index template, custom</h1>
                          <ul>
                            <% @collection.each do |rule| %>
                              <li><%= link_to rule.name, "./#{rule.name}/index.html" %></li>
                            <% end %>
                          </ul>',
          layout: '<html>
                    <head>
                      <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
                    </head>
                    <body>
                    <h1>layout header</h1>
                    <div class="container">
                      <%= yield %>
                    </div>
                    <footer>layout footer</footer>
                    <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
                    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
                    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
                    </body>
                  </html>',
          after_zip: ->(o, r){ puts "THIS IS GREAT #{o} was zipped, now what ??" }

        }

        c.add_portability_rule({
          name: "exportable_data", 
          collection: :foo_data, 
          template: "hellow , here a collection will be rendered
          <%= @base_path %>
           <% @collection.each do |item| %>
            <p><%= item.country%></p>

           <% end %>
           <%= will_paginate(@collection, renderer: PolicyManager::PaginatorRenderer) %>",
          per: 10
        })

        c.add_portability_rule({
          name: "my_account", 
          member: :account_data,
          template: "hellow , here a resource will be rendered <%= image_tag(@member[:image]) %> <%= @member[:name] %> "          
        })

        c.add_portability_rule({
          name: "my_account_from_template", 
          member: :account_data,
          template: Rails.root.join("app/views").join("template.erb")
        })

      end

      PolicyManager::Term.create(description: "el", rule: "age")

    end

    test "instance of exporter" do
      assert @config.exporter.is_a?(Exporter)
    end

    test "initialize folder & clear folder" do
      person = OpenStruct.new(id: 1, name: "John Smith")
      PolicyManager::ExporterHandler.stub_any_instance(:clear!, true) do
        PolicyManager::ExporterHandler.stub_any_instance(:handle_zip_upload, true) do
          @config.exporter.perform(person)
        end
      end
      assert File.exist?(Rails.root + "tmp/export/1")
      @config.exporter.clear!(person)
      assert !File.exist?(Rails.root + "tmp/export/1")
    end

    test "user export will generate folder, layout, templates" do
      User.stub_any_instance(:enabled_for_validation, false) do
        user = User.create(email: "a@a.cl")
        assert !user.errors.any?
        PolicyManager::ExporterHandler.stub_any_instance(:clear!, true) do
          
          PolicyManager::ExporterHandler.stub_any_instance(:handle_zip_upload, true) do
            @config.exporter.perform(user)
          end

          assert File.exists?(Rails.root.join("tmp/export/#{user.id}"))
          paths = Dir.glob( Rails.root.join("tmp/export/#{user.id}") + "*")
          names = paths.map{|o| File.basename(o) }
          arr = names - ["exportable_data", "index.html", "my_account", "my_account_from_template"]
          assert arr.empty?
          noko = Nokogiri::HTML.parse( File.open(paths.first + "/index.html").read )
          assert noko.css("h1").text == "layout header"
          assert noko.css("footer").text == "layout footer"
        end

        FileUtils.rm_rf(Rails.root.join("tmp/export/#{user.id}"))
        FileUtils.rm_rf(Rails.root.join("tmp/export/#{user.id}-out.zip"))
      
      end
    end

  end
end
