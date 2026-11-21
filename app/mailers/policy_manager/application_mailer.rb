module PolicyManager
  class ApplicationMailer < ActionMailer::Base
    default from: Config.from_email
    layout 'mailer'

    # configurable mailer helpers
    # Strings let hosts name helpers without autoloading them from an initializer.
    if Config.exporter.present?
      Array(Config.exporter.mail_helpers).each do |mail_helper|
        helper(mail_helper.is_a?(String) ? mail_helper.constantize : mail_helper)
      end
    end
  end
end
