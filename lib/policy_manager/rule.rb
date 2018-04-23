module PolicyManager
  class Rule
    attr_accessor :validates_on, :if, :blocking, :name

    def initialize(opts={})
      self.name = opts[:name]
      self.blocking = opts[:blocking]
      self.validates_on = opts[:validates_on]
      self.if = opts[:if]
      self
    end

    def validates_on
      @validates_on #|| [:create]
    end

    def terms
      Term.where("rule =?", self.name)
    end

  end
end