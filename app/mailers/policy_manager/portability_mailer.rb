module PolicyManager
  class PortabilityMailer < ApplicationMailer
    def progress_notification(portability_request_id)
      @portability_request = PortabilityRequest.find(portability_request_id)
      @user = find_user_resource(@portability_request.user_id)

      opts = { from: Config.from_email, to: @user.email, subject: I18n.t('terms_app.mails.progress.subject') }
      if has_custom_template?(:progress)
        opts.merge!({
                      template_path: PolicyManager::Config.exporter.mailer_templates[:path].to_s,
                      template_name: PolicyManager::Config.exporter.mailer_templates[:progress]
                    })
      end

      set_mail_lang

      mail(opts)
    end

    def completed_notification(portability_request_id)
      @portability_request = PortabilityRequest.find(portability_request_id)
      @user = find_user_resource(@portability_request.user_id)
      @link = @portability_request.download_link

      opts = { from: Config.from_email, to: @user.email, subject: I18n.t('terms_app.mails.completed.subject') }
      if has_custom_template?(:complete)
        opts.merge!({
                      template_path: PolicyManager::Config.exporter.mailer_templates[:path].to_s,
                      template_name: PolicyManager::Config.exporter.mailer_templates[:complete]
                    })
      end

      set_mail_lang

      mail(opts)
    end

    def admin_notification(user_id)
      @user = find_user_resource(user_id)

      opts = { from: Config.from_email, to: Config.admin_email(@user),
               subject: I18n.t('terms_app.mails.admin.subject', email: @user.email) }
      if has_custom_template?(:admin)
        opts.merge!({
                      template_path: PolicyManager::Config.exporter.mailer_templates[:path].to_s,
                      template_name: PolicyManager::Config.exporter.mailer_templates[:admin]
                    })
      end

      set_mail_lang

      mail(opts)
    end

    private

    def set_mail_lang
      I18n.locale = Config.user_language(@user)
    end

    def has_custom_template?(template)
      return false if PolicyManager::Config.exporter.mailer_templates.blank?

      PolicyManager::Config.exporter.mailer_templates[template].present? && PolicyManager::Config.exporter.mailer_templates[:path].to_s.present?
    end

    def find_user_resource(user_id)
      user_model = if Config.user_resource.is_a?(String)
                     Config.user_resource.constantize
                   else
                     Config.user_resource
                   end
      user_model.find(user_id)
    end
  end
end
