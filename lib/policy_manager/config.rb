module PolicyManager
  class Config

    mattr_accessor :exporter,
                   :from_email,
                   :is_admin_method,
                   :logout_url,
                   :user_language_method,
                   :scripts,
                   :admin_email_inbox,
                   :error_notifier,
                   :user_resource,
                   :admin_user_resource,
                   :paperclip

    def self.setup
      @@rules = []
      @@portability_rules = []
      @@portability_templates = []
      @@scripts = []

      yield self

      # sets this defaults after configuration
      @@user_resource ||= 'User'
      @@admin_user_resource ||= @@user_resource

      self
    end

    def self.error_notifier_method(error)
      puts error
      @@error_notifier.call(error) unless @@error_notifier.blank?
    end

    def self.admin_email(user)
      @@admin_email_inbox.is_a?(Proc) ? @@admin_email_inbox.call(user) : @@admin_email_inbox
    end

    def self.exporter=(opts)
      @@exporter = Exporter.new(opts)
    end

    def self.is_admin?(user)
      if has_different_admin_user_resource?
        user.is_a? admin_user_resource
      else
        raise Rails.logger.error("GDPR ERROR! please add is_admin_method to your gdpr initializer") if @@is_admin_method.blank?
        @@is_admin_method.call(user)
      end
    end

    def self.has_different_admin_user_resource?
      user_resource != admin_user_resource
    end

    def self.user_language(user)
      @@user_language_method.call(user) rescue :en
    end

    def self.rules
      @@rules ||= []
    end

    def self.portability_rules
      @@portability_rules ||= []
    end

    def self.add_rule(opts={}, &block)
      @@rules << PolicyManager::Rule.new(opts, &block)
    end

    def self.add_portability_rule(opts={}, &block)
      @@portability_rules << PolicyManager::PortabilityRule.new(opts, &block)
    end

    def self.add_script(opts={}, &block)
      @@scripts << PolicyManager::Script.new(opts, &block)
    end

  end
end
