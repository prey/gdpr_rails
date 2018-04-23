module PolicyManager
  class ApplicationMailer < ActionMailer::Base
    default from: Config.from_email
    layout 'mailer'

    # configurable mailer helpers
    Config.exporter.mail_helpers.each do |helpers|
      add_template_helper(helpers)
    end

    def send!(opts = {})

      I18n.locale = Config.user_language(@user)

      default_opts = {
        :to => @user.email, 
        :subject => @subject
      }.merge(opts)

      mail(default_opts)
    end

  end
end