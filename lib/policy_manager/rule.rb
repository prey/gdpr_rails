module PolicyManager
  class Rule
    attr_accessor :validates_on,
                  :if,
                  :blocking,
                  :name,
                  :on_reject,
                  :on_accept

    def initialize(opts = {})
      self.name = opts[:name]
      self.blocking = opts[:blocking]
      self.validates_on = opts[:validates_on]
      self.if = opts[:if]
      self.on_reject = opts[:on_reject]
      self.on_accept = opts[:on_accept]
    end

    attr_reader :validates_on

    def terms
      Term.where('rule =?', name)
    end

    def on_reject_callback
      @on_reject.call if @on_reject.is_a?(Proc)
    end

    def on_accept_callback
      @on_accept.call if @on_accept.is_a?(Proc)
    end
  end
end
