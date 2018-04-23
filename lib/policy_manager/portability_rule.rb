module PolicyManager
  class PortabilityRule
    attr_accessor :name, :methods, :formats, :per, :collection, :member, :template

    def initialize(opts={})
      self.collection = opts[:collection]
      self.member = opts[:member]
      self.per = opts[:per]
      self.name = opts[:name]
      self.formats = opts[:formats]
      self.template = opts[:template]
    end

  end
end