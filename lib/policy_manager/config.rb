module PolicyManager
  class Config

    mattr_accessor :exporter, :from_email, :is_admin_method, :logout_url, :portability_templates, :user_language_method

    def self.setup
      @@rules = []
      @@portability_rules = []
      @@portability_templates = []
      yield self
      self
    end
    
    def self.exporter=(opts)
      @@exporter = Exporter.new(opts)
    end

    def self.is_admin?(user)
      @@is_admin_method.call(user)
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

  end
end