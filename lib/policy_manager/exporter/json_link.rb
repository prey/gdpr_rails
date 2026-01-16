module PolicyManager
  class JsonLink
    def self.render(collection = nil)
      ActionController::Base.helpers.content_tag(:a, 'Open as JSON', href: link(collection), target: '_blank')
    end

    def self.link(_collection)
      './data.json'
    end
  end
end
