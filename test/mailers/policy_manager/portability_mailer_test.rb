require 'test_helper'

module PolicyManager
  class PortabilityMailerTest < ActionMailer::TestCase
    
    def setup
      @exporter_config = { 
        path: Rails.root + "tmp/export", 
        resource: User ,
        index_template: '<h1>index template, custom</h1>
                        <ul>
                          <% @collection.each do |rule| %>
                            <li><%= link_to rule.name, "./#{rule.name}/index.html" %></li>
                          <% end %>
                        </ul>',
        layout: "<body>
                <h1>layout header</h1>
                <%= yield %>
                <footer>layout footer</footer>
                </body>",
        after_zip: ->(zip_path, resource){ 
          puts "THIS IS GREAT #{zip_path} was zipped, now what ??" 
        }
      }
    end

    test "progress notification with custom template" do

      @config = PolicyManager::Config.setup do |c|
        c.from_email = "foo@bar.org"
        c.admin_email_inbox = "foo@baaz.org"
        c.exporter = @exporter_config.merge({mailer_templates: {
            path: "user_mailer",
            progress: "progress"
          }
        })
      end

      user = User.create(email: "a@a.cl")
      assert !user.errors.any?
      preq = user.portability_requests.create
      preq.confirm!

      sent_email = PortabilityMailer.progress_notification(preq.id)

      assert_equal [@config.from_email], sent_email.from
      assert_equal [user.email], sent_email.to
      assert_equal 'Your data is being handled', sent_email.subject
      assert_match 'in progress!', sent_email.body.to_s
    end

    test "progress notification with default template" do

      @config = PolicyManager::Config.setup do |c|
        c.from_email = "foo@bar.org"
        c.admin_email_inbox = "foo@baaz.org"
        c.exporter = @exporter_config
      end
      user = User.create(email: "a@a.cl")
      assert !user.errors.any?
      preq = user.portability_requests.create
      preq.confirm!

      sent_email = PortabilityMailer.progress_notification(preq.id)

      assert_equal [@config.from_email], sent_email.from
      assert_equal [user.email], sent_email.to
      assert_equal 'Your data is being handled', sent_email.subject
      assert_match 'hello your files are being downloaded', sent_email.body.to_s
    end

    test "completed notification with custom template" do

      @config = PolicyManager::Config.setup do |c|
        c.from_email = "foo@bar.org"
        c.admin_email_inbox = "foo@baaz.org"
        c.exporter = @exporter_config.merge!({mailer_templates: {
            path: "user_mailer",
            complete: "complete",
            progress: "progress"
          }
        })
      end

      user = User.create(email: "a@a.cl")
      assert !user.errors.any?
      preq = user.portability_requests.create
      preq.confirm!
      preq.complete!

      sent_email = PortabilityMailer.completed_notification(preq.id)

      assert_equal [@config.from_email], sent_email.from
      assert_equal [user.email], sent_email.to
      assert_equal 'Your data is available', sent_email.subject
      assert_match 'completed!', sent_email.body.to_s
    end

    test "completed notification with default template" do

      @config = PolicyManager::Config.setup do |c|
        c.from_email = "foo@bar.org"
        c.admin_email_inbox = "foo@baaz.org"
        c.exporter = @exporter_config
      end

      user = User.create(email: "a@a.cl")
      assert !user.errors.any?
      preq = user.portability_requests.create
      preq.confirm!
      preq.complete!

      sent_email = PortabilityMailer.completed_notification(preq.id)

      assert_equal [@config.from_email], sent_email.from
      assert_equal [user.email], sent_email.to
      assert_equal 'Your data is available', sent_email.subject
      assert_match 'your complete data was processed and can be downloaded', sent_email.body.to_s
    end

    test "admin notification with custom template" do

      @config = PolicyManager::Config.setup do |c|
        c.from_email = "foo@bar.org"
        c.admin_email_inbox = -> (o){ "foo@bar.org" }
        c.exporter = @exporter_config.merge({mailer_templates: {
            path: "user_mailer",
            complete: "complete",
            progress: "progress",
            admin: "admin"
          }
        })
      end

      user = User.create(email: "a@a.cl")
      assert !user.errors.any?
      preq = user.portability_requests.create
      preq.confirm!

      sent_email = PortabilityMailer.admin_notification(user.id)

      assert_equal [@config.from_email], sent_email.from
      assert_equal [@config.from_email], sent_email.to
      assert_equal 'User ' + user.email + ' sent a portability request', sent_email.subject
      assert_match 'admin portability notification', sent_email.body.to_s
    end

    test "admin notification with default template" do

      @config = PolicyManager::Config.setup do |c|
        c.from_email = "foo@bar.org"
        c.exporter = @exporter_config
        c.admin_email_inbox = "foo@bar.org"
      end
      
      user = User.create(email: "a@a.cl")
      assert !user.errors.any?
      preq = user.portability_requests.create
      preq.confirm!

      sent_email = PortabilityMailer.admin_notification(user.id)

      assert_equal [@config.from_email], sent_email.from
      assert_equal [@config.from_email], sent_email.to
      assert_equal 'User ' + user.email + ' sent a portability request', sent_email.subject
      assert_match 'hello, the user ' + user.email + ' sent a portability request.', sent_email.body.to_s
    end

  end
end
