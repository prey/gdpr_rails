require 'redcarpet'
require 'aasm'

module PolicyManager
  class Term < ApplicationRecord
    include AASM

    validates_presence_of :rule
    validates_presence_of :description
    validates_presence_of :state

    aasm column: :state do
      state :draft, initial: true # db column's default
      state :published

      event :publish do
        transitions from: :draft, to: :published
      end

      event :unpublish do
        transitions from: :published, to: :draft
      end
    end

    def self.renderer
      @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    end

    def to_html
      self.class.renderer.render(description)
    end

    def rule
      PolicyManager::Config.rules.find { |o| o.name == self[:rule] }
    end
  end
end
