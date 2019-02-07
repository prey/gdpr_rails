require 'spec_helper'
require 'ostruct'

describe PolicyManager::Exporter do

  before(:each) do
    PolicyManager::Term.create(description: "el", rule: "age")

    @config = PolicyManager::Config.setup do |c|
      c.add_rule({name: "age", validates_on: [:create, :update],
                  if: ->(o){ o.enabled_for_validation } })
      c.exporter = {
        path: Rails.root + "tmp/export",
        resource: 'User' ,
        index_template: '<h1>index template, custom</h1>
                        <ul>
                          <% @collection.each do |rule| %>
                            <li><%= link_to rule.name, "./#{rule.name}/index.html" %></li>
                          <% end %>
                        </ul>',
        layout: 'portability',
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
        json_template: Rails.root.join("app/views/collection.json.jbuilder"),
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

  it "instance of exporter" do
    assert @config.exporter.is_a?(PolicyManager::Exporter)
  end

  it "initialize folder & clear folder" do
    person = OpenStruct.new(id: 1, name: "John Smith")
    PolicyManager::ExporterHandler.any_instance.stubs(:clear!).returns(true)
    PolicyManager::ExporterHandler.any_instance.stubs(:handle_zip_upload).returns(true)
    @config.exporter.perform(person)
    assert File.exist?(Rails.root + "tmp/export/1")

    FileUtils.rm_rf(Rails.root.join("tmp/export/#{person.id}"))
    FileUtils.rm_rf(Rails.root.join("tmp/export/#{person.id}-out.zip"))

  end

  it "user export will generate folder, layout, templates" do
    User.any_instance.stubs(:enabled_for_validation).returns(false)
    user = User.create(email: "a@a.cl")
    assert !user.errors.any?
    PolicyManager::ExporterHandler.any_instance.stubs(:clear!).returns(true)

    PolicyManager::ExporterHandler.any_instance.stubs(:handle_zip_upload).returns(true)
    @config.exporter.perform(user)

    assert File.exists?(Rails.root.join("tmp/export/#{user.id}"))
    paths = Dir.glob( Rails.root.join("tmp/export/#{user.id}") + "*")
    names = paths.map{|o| File.basename(o) }
    arr = names - ["exportable_data", "index.html", "my_account", "my_account_from_template"]
    assert arr.empty?
    noko = Nokogiri::HTML.parse( File.open(paths.first + "/index.html").read )
    assert noko.css("h1").text == "layout header"
    assert noko.css("footer").text == "layout footer"

    FileUtils.rm_rf(Rails.root.join("tmp/export/#{user.id}"))
    FileUtils.rm_rf(Rails.root.join("tmp/export/#{user.id}-out.zip"))


  end

end

