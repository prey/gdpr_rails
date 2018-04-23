module PolicyManager
  class PortabilityMailer < ApplicationMailer

    def progress_notification(portability_request_id)
      @portability_request = PortabilityRequest.find(portability_request_id)
      @user = User.find(@portability_request.user_id)
      @subject = I18n.t("terms_app.mails.progress.subject")
      
      opts = {}
      opts.merge!({
        template_path: PolicyManager::Config.exporter.mailer_templates[:path].to_s, 
        template_name: PolicyManager::Config.exporter.mailer_templates[:progress]
      }) if PolicyManager::Config.exporter.mailer_templates.present?
      
      send!(opts)
    end

    def completed_notification(portability_request_id)
      @portability_request = PortabilityRequest.find(portability_request_id)
      @user = User.find(@portability_request.user_id)
      @subject = I18n.t("terms_app.mails.completed.subject")
      @link = @portability_request.download_link
      
      opts = {}
      opts.merge!({
        template_path: PolicyManager::Config.exporter.mailer_templates[:path].to_s, 
        template_name: PolicyManager::Config.exporter.mailer_templates[:complete]
      }) if PolicyManager::Config.exporter.mailer_templates.present?
      
      send!(opts)
    end

  end
end
