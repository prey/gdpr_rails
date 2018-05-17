module PolicyManager
  class JsonLink

    def self.render(collection = nil)
      ActionController::Base.helpers.content_tag(:a, "Open as JSON", href: link(collection), target: '_blank')
    end

    private

    def self.link(collection)
      return "./data.json"
    end

  end
end