require 'spec_helper'

describe PolicyManager::PortabilityRequest do

    context "active storage default" do 
      before :each do

        PolicyManager::Term.create(description: "el", rule: "age")

        @config = PolicyManager::Config.setup do |c|
          c.from_email = "foo@bar.org"
          c.admin_email_inbox = "foo@baaz.org"
          c.add_rule({name: "age", validates_on: [:create, :update], if: ->(o){ o.enabled_for_validation } })
          c.exporter = {
            path: Rails.root + "tmp/export",
            resource: 'User' ,
            index_template: '
            <h1>index template, custom</h1>
                            <ul>
                              <% @collection.each do |rule| %>
                                <li><%= link_to rule.name, "./#{rule.name}/index.html" %></li>
                              <% end %>
                            </ul>',
            layout: 'portability_requests',
            after_zip: ->(zip_path, resource){
              puts "THIS IS GREAT #{zip_path} was zipped, now what ??"
            }

          }

          c.add_portability_rule({
            name: "exportable_data",
            collection: :foo_data,
            template: "hello , here a collection will be
            rendered <%= @collection.to_json %>
            <%= will_paginate(@collection, renderer: PolicyManager::PaginatorRenderer) %>",
            per: 10
          })

        end

        PolicyManager::Term.create(description: "el", rule: "age")
      end

      it "user export will generate folder, layout, templates" do

        User.any_instance.stubs(:enabled_for_validation).returns(false)
          User.any_instance.stubs(:foo_data).returns( (1..100).to_a)
            user = User.create(email: "a@a.cl")
            FileUtils.rm_rf(Rails.root.join("tmp/export"))
            assert !user.errors.any?
            preq = user.portability_requests.create
            assert preq.pending?

            PolicyManager::ExporterHandler.any_instance.stubs(:clear!).returns(true)
            preq.confirm!
            assert preq.progress?
            notification = ActionMailer::Base.deliveries.last
            assert notification.present?

            expect(File.exists?(Rails.root.join("tmp/export/#{user.id}"))).to be_truthy
            paths = Dir.glob( Rails.root.join("tmp/export/#{user.id}") + "*")
            names = paths.map{|o| File.basename(o) }
            arr = names - ["exportable_data", "index.html", "my_account", "my_account_from_template"]
            assert arr.empty?
            
            noko = Nokogiri::HTML.parse( File.open(paths.first + "/index.html").read )

            assert noko.css("h1:first").text == "layout header"
            assert noko.css("footer").text == "layout footer"

            expect(preq.reload).to be_completed

            notification = ActionMailer::Base.deliveries.last
            assert Nokogiri::HTML.parse(notification.body.raw_source).css("a").attr("href").value.include?("#{user.id}-out.zip")

            FileUtils.rm_rf(Rails.root.join("tmp/export/#{user.id}"))
            FileUtils.rm_rf(Rails.root.join("tmp/export/#{user.id}-out.zip"))

      end
    end


    context 'paperclip' do
      # Dry this. it's just a paperclip version of the spec above
      before :each do

        PolicyManager::Term.create(description: "el", rule: "age")

        @config = PolicyManager::Config.setup do |c|
          c.from_email = "foo@bar.org"
          c.paperclip = true
          c.admin_email_inbox = "foo@baaz.org"
          c.add_rule({name: "age", validates_on: [:create, :update], if: ->(o){ o.enabled_for_validation } })
          c.exporter = {
            path: Rails.root + "tmp/export",
            resource: 'User' ,
            index_template: '
            <h1>index template, custom</h1>
                            <ul>
                              <% @collection.each do |rule| %>
                                <li><%= link_to rule.name, "./#{rule.name}/index.html" %></li>
                              <% end %>
                            </ul>',
            layout: 'portability_requests',
            after_zip: ->(zip_path, resource){
              puts "THIS IS GREAT #{zip_path} was zipped, now what ??"
            }

          }

          c.add_portability_rule({
            name: "exportable_data",
            collection: :foo_data,
            template: "hello , here a collection will be
            rendered <%= @collection.to_json %>
            <%= will_paginate(@collection, renderer: PolicyManager::PaginatorRenderer) %>",
            per: 10
          })

        end

        PolicyManager::Term.create(description: "el", rule: "age")
      end

      it "user export will generate folder, layout, templates" do

        User.any_instance.stubs(:enabled_for_validation).returns(false)
          User.any_instance.stubs(:foo_data).returns( (1..100).to_a)
            user = User.create(email: "a@a.cl")
            FileUtils.rm_rf(Rails.root.join("tmp/export"))
            assert !user.errors.any?
            preq = user.portability_requests.create
            assert preq.pending?

            PolicyManager::ExporterHandler.any_instance.stubs(:clear!).returns(true)
            preq.confirm!
            assert preq.progress?
            notification = ActionMailer::Base.deliveries.last
            assert notification.present?

            expect(File.exists?(Rails.root.join("tmp/export/#{user.id}"))).to be_truthy
            paths = Dir.glob( Rails.root.join("tmp/export/#{user.id}") + "*")
            names = paths.map{|o| File.basename(o) }
            arr = names - ["exportable_data", "index.html", "my_account", "my_account_from_template"]
            assert arr.empty?
            
            noko = Nokogiri::HTML.parse( File.open(paths.first + "/index.html").read )

            assert noko.css("h1:first").text == "layout header"
            assert noko.css("footer").text == "layout footer"

            expect(preq.reload).to be_completed

            notification = ActionMailer::Base.deliveries.last
            assert Nokogiri::HTML.parse(notification.body.raw_source).css("a").attr("href").value.include?("#{user.id}-out.zip")

            FileUtils.rm_rf(Rails.root.join("tmp/export/#{user.id}"))
            FileUtils.rm_rf(Rails.root.join("tmp/export/#{user.id}-out.zip"))

      end
    end

end
