require 'erb'
require 'open-uri'
require 'will_paginate'
require 'will_paginate/view_helpers'
require 'will_paginate/view_helpers/action_view'

module PolicyManager
  class ExporterView
    include ERB::Util
    include ActionView::Helpers
    include WillPaginate::ViewHelpers # if defined?(WillPaginate)
    include WillPaginate::ActionView # if defined?(WillPaginate)

    attr_accessor :template, :base_path, :assigns

    def self.template
      'Welcome, <%= @name %>'
    end

    def initialize(options = {}, _date = Time.now)
      @base_path = options[:base_path]
      @build_path = options[:build_path]
      self.assigns = options[:assigns]
      index_path
      @template = options.fetch(:template, self.class.template)
    end

    def index_path
      path = @base_path.to_s.gsub(@build_path.to_s, '')
      len = path.split('/').size
      @index_path = case len
                    when 2
                      './'
                    when 3
                      '../'
                    when 4
                      '../../'
                    else
                      '../../'
                    end
    end

    def render
      ac = PolicyManager::ExporterController.new
      options = handled_template.merge!({
                                          assigns: assigns.merge!({
                                                                    base_path: base_path,
                                                                    build_path: @build_path,
                                                                    index_path: index_path
                                                                  }),
                                          layout: PolicyManager::Config.exporter.layout
                                        })
      ac.render_to_string(options)
    end

    def save(file)
      File.open(file, 'w+') do |f|
        f.write(render)
      end
    end

    # TODO: method duplicated from json
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
