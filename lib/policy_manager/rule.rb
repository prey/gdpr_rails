module PolicyManager
  class Rule
    attr_accessor :validates_on, 
    :if, 
    :blocking, 
    :name, 
    :on_reject,
    :on_accept

    def initialize(opts={})
      self.name = opts[:name]
      self.blocking = opts[:blocking]
      self.validates_on = opts[:validates_on]
      self.if = opts[:if]
      self.on_reject = opts[:on_reject]
      self.on_accept = opts[:on_accept]
      self
    end

    def validates_on
      @validates_on #|| [:create]
    end

    def terms
      Term.where("rule =?", self.name)
    end

    def on_reject_callback
      @on_reject.call if @on_reject.is_a?(Proc)
    end

    def on_accept_callback
      @on_accept.call if @on_accept.is_a?(Proc)
    end

  end
end