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
    
    attr_accessor :template, :base_path, :assigns

    def self.template
      "Welcome, <%= @name %>"
    end

    def initialize(options={}, date=Time.now)
      @base_path = options[:base_path]
      @build_path = options[:build_path]
      self.assigns = options[:assigns]
      index_path
      @template = options.fetch(:template, self.class.template)
      return self
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

    def render()
      context = self
      ac = PolicyManager::ExporterController.new()
      options = handled_template.merge!({
        assigns: self.assigns.merge!({
          base_path: base_path, 
          build_path: @build_path,
          index_path: index_path
        }),
        layout: PolicyManager::Config.exporter.layout 
      })
      ac.render_to_string(options)
    end

    def save(file)
      File.open(file, "w+") do |f|
        f.write(render)
      end
    end

    # TODO: method duplicated from json
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