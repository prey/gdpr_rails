require "erb"
require 'open-uri'
require "tilt"
require "will_paginate"
require 'will_paginate/view_helpers'
require 'will_paginate/view_helpers/action_view'


module PolicyManager
  class ExporterView
    
    include ERB::Util
    include ActionView::Helpers
    include WillPaginate::ViewHelpers #if defined?(WillPaginate)
    include WillPaginate::ActionView #if defined?(WillPaginate)
    
    attr_accessor :template, :base_path

    def self.template
      "Welcome, <%= @name %>"
    end

    def initialize(vars={}, options={}, date=Time.now)
      # collection or member, or wathever!?
      vars.each{|k, v| self.instance_variable_set("@#{k}", v)}
      @base_path = options[:base_path]
      @build_path = options[:build_path]

      index_path

      @template = options.fetch(:template, self.class.template)

    end

    def index_path
      path = @base_path.to_s.gsub(@build_path.to_s, "")
      len = path.split("/").size 
      case len
      when 2
        @index_path = "./"
      when 3
        @index_path = "../"
      when 4
        @index_path = "../../"
      else
        @index_path = "../../"
      end
    end

    def image_tag(remote_image, opts={})
      begin
        basename = File.basename(remote_image)
        id = opts[:id] || SecureRandom.hex(10)
        composed_name = [id, basename].compact.join("-")
        path = "#{File.dirname(base_path)}/#{composed_name}"
        self.save_image(remote_image, path)
        tag(:img, {src: "./#{id}-#{File.basename(URI(remote_image).path)}" }.merge(opts))
      rescue => e
        Bugsnag.notify(e)
        content_tag(:p, "broken image")
      end
    end

    def save_image(remote_image, path)
      open(URI(path).path, 'wb') do |file|
        file << open(remote_image).read
      end
    end

    def render()
      #template_layout = Tilt::ERBTemplate.new {PolicyManager::Config.exporter.layout}
      context = self
      #template_layout.render { 
      #  view = Tilt::ERBTemplate.new{handled_template}
      #  view.render(context)
      #}

      render_with_layout()      
    end

    def render_with_layout(context = self)
      render_layout do
        ERB.new(handled_template).result(binding)
      end
    end

    def render_layout
      layout = PolicyManager::Config.exporter.layout #File.read('views/layouts/app.html.erb')
      ERB.new(layout).result(binding)
    end


    def save(file)
      File.open(file, "w+") do |f|
        f.write(render)
      end
    end

    def handled_template
      if @template.is_a?(String) 
        @template
      elsif @template.is_a?(Pathname)
        File.open(@template).read
      end
    end

  end
end