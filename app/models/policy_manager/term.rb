require "redcarpet"

module PolicyManager
  class Term < ApplicationRecord

    validates_presence_of :rule

    def self.renderer
      @markdown = markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    end

    def to_html
      self.class.renderer.render(self.description)
    end

    def rule
      PolicyManager::Config.rules.find{|o| o.name == self[:rule]}
    end
  end
end
