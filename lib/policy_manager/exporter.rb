require 'fileutils'

module PolicyManager
  class Exporter
    attr_accessor :path,
                  :resource,
                  :index_template,
                  :layout,
                  :after_zip,
                  :mail_helpers,
                  :attachment_path,
                  :attachment_storage,
                  :expiration_link,
                  :customize_link,
                  :mailer_templates,
                  :mailer

    def initialize(opts = {})
      self.path = opts[:path]
      self.resource = opts[:resource] # .call if opts[:resource].is_a?(Proc)
      self.index_template = opts[:index_template]
      self.layout = opts[:layout]
      self.after_zip = opts[:after_zip]
      self.mail_helpers = opts[:mail_helpers]
      self.attachment_path = opts[:attachment_path]
      self.attachment_storage = opts[:attachment_storage]
      self.expiration_link = opts[:expiration_link]
      self.customize_link = opts[:customize_link]
      self.mailer_templates = opts[:mailer_templates]
    end

    def perform(resource)
      e = ExporterHandler.new(resource: resource, path: path, after_zip: after_zip)
      e.perform
    end

    def clear!(resource)
      e = ExporterHandler.new(resource: resource, path: path)
      e.clear!
    end

    def index_template
      handled_template(@index_template) || default_index_template
    end

    def layout
      handled_template(@layout) || 'policy_manager/portability'
    end

    def mail_helpers
      @mail_helpers ||= []
    end

    def expiration_link
      @expiration_link ||= 60
    end

    def customize_link(url)
      @customize_link.is_a?(Proc) ? @customize_link.call(url) : url
    end

    def handled_template(template)
      return if template.blank?

      if template.is_a?(String)
        template
      elsif template.is_a?(Pathname)
        File.open(template).read
      end
    end

    def default_index_template
      '<h1>links</h1>
      <ul>
        <% @collection.each do |rule| %>
          <li><%= link_to rule.name, "./#{rule.name}" %></li>
        <% end %>
      </ul>'
    end
  end
end
