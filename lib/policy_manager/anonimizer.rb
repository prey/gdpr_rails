# c.anonimizer do |a|
#  c.secret_key = "oeoeo123eoeo"
#  c.encryptor = :sha512
#  c.rule(on: User, fields: [:email])
# end

module PolicyManager
  class Anonimizer
    attr_accessor :secret_key, :encryptor, :rules

    def initialize(opts = {})
      self.path = opts[:path]
    end
  end
end
