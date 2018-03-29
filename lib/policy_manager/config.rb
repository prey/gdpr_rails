module PolicyManager
  class Config

    def self.setup
      @@rules = []
      yield self
      self
    end
    
    def self.rules
      @@rules
    end

    def self.add_rule(opts={}, &block)
      @@rules << PolicyManager::Rule.new(opts, &block)
    end

  end
end