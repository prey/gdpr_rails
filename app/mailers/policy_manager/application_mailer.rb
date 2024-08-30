module PolicyManager
  class ApplicationMailer < ActionMailer::Base
    default from: Config.from_email
    layout 'mailer'

    # configurable mailer helpers
    if Config.exporter.present?
      Config.exporter.mail_helpers.each do |helpers|
        if Rails::VERSION::MAJOR > 6 && Rails::VERSION::MINOR > 0
          helper(helpers)
        else
          add_template_helper(helpers)
        end
      end
    end
  end
end
