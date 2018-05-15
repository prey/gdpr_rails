require "fileutils"

module PolicyManager
  class JsonExporterView
    attr_accessor :template, :folder, :assigns

    def initialize(vars={}, options)
      self.folder = options[:folder]
      self.assigns = options[:assigns]
      @template = options.fetch(:template) #, self.class.template)
      return self
    end

    def save
      render_json
    end

    def save_json(file, data)
      File.open(file, "w") do |f|
        f.write(data)
      end
    end

    def render_json
      ac = PolicyManager::ExporterController.new()
      options = handled_template.merge!({assigns: self.assigns })
      content = ac.render_to_string(options)
      save_json("#{folder}/data.json", content)
    end

    def handled_template
      begin
        if URI.parse(@template)
          return {template: @template}
        end
      rescue URI::InvalidURIError
      end

      if @template.is_a?(String) 
        return {inline: @template}
      elsif @template.is_a?(Pathname)
        return {file: @template }
      end
    end

  end
end