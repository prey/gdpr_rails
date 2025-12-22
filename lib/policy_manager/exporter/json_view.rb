require 'fileutils'

module PolicyManager
  class JsonExporterView
    attr_accessor :template, :folder, :assigns

    def initialize(assigns:, folder:, template:)
      self.folder = folder
      self.assigns = assigns
      @template = template
    end

    def save
      render_json
    end

    def save_json(file, data)
      File.open(file, 'w') do |f|
        f.write(data)
      end
    end

    def render_json
      ac = PolicyManager::ExporterController.new
      options = handled_template.merge!({ assigns: assigns })
      content = ac.render_to_string(options)
      save_json("#{folder}/data.json", content)
    end

    def handled_template
      begin
        return { template: @template } if URI.parse(@template)
      rescue URI::InvalidURIError
      end

      if @template.is_a?(String)
        { inline: @template }
      elsif @template.is_a?(Pathname)
        { file: @template }
      end
    end
  end
end
