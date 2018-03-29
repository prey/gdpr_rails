module PolicyManager
  class Rule
    attr_accessor :resources, :blocking, :name

    def initialize(opts={})
      self.name = opts[:name]
      self.blocking = opts[:blocking]
      self.resources = opts[:resources]
    end

    def resources
      @resources || [:internal]
    end

    def terms
      Term.where("rule =?", self.name)
    end

  end
end