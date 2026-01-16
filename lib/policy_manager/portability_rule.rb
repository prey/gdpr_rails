module PolicyManager
  class PortabilityRule
    attr_accessor :name,
                  :methods,
                  :formats,
                  :per,
                  :collection,
                  :member,
                  :template,
                  :json_template

    def initialize(opts = {})
      self.collection = opts[:collection]
      self.member = opts[:member]
      self.per = opts[:per]
      self.name = opts[:name]
      self.formats = opts[:formats]
      self.template = opts[:template]
      self.json_template = opts[:json_template]
    end
  end
end
