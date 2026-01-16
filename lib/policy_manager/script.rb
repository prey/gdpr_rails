module PolicyManager
  class Script
    include ActiveModel::Serialization

    attr_accessor :script,
                  :name,
                  :environments,
                  :cookies,
                  :description,
                  :permanent,
                  :domain

    def initialize(opts = {})
      self.name = opts[:name]
      self.script = opts[:script]
      self.cookies = opts[:cookies]
      self.environments = opts[:environments]
      self.description = opts[:description]
      self.permanent = opts[:permanent]
      self.domain = opts[:domain]
    end

    def can_render?
      environments.map(&:to_s).include?(Rails.env)
    end

    def description
      @description.is_a?(Proc) ? @description.call : @description
    end

    def as_json(_opts = {})
      data = {}
      fields = %i[script name cookies description]
      fields.each { |k| data[k] = send(k) }
      data
    end

    def self.cookies
      PolicyManager::Config
        .scripts
        .select { |o| o.cookies.present? }
    end

    def self.cookies_permanent
      PolicyManager::Config
        .scripts
        .select { |o| o.cookies.present? && o.permanent? }
    end

    def self.scripts
      PolicyManager::Config.scripts.select { |o| o.script.present? }
    end
  end
end
