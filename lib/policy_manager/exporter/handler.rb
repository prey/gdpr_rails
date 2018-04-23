require "fileutils"
require 'zip'

module PolicyManager
  class ExporterHandler
    attr_accessor :resource, :path, :after_zip

    def initialize(opts={})
      self.path = opts[:path]
      self.resource = opts[:resource]
      self.after_zip = opts[:after_zip] if opts[:after_zip]
    end

    def base_path
      self.path.join resource.id.to_s
    end

    def zip_path
      "#{base_path}-out.zip"
    end

    def perform
      FileUtils.mkdir_p(base_path)
      create_sections
      generate_zip
      handle_zip_upload
      after_zip.call(zip_path, resource)
      clear!
    end

    def handle_zip_upload
      resource
      .portability_requests
      .find_by(state: "progress")
      .update_attributes(file_remote_url: zip_path)
    end

    def clear!
      FileUtils.rm_rf(base_path)
      FileUtils.rm_rf(zip_path)
    end

    def create_sections
      PolicyManager::Config.portability_rules.each do |rule|
        handle_render_for(rule)
      end

      render_index
      puts "FOLDER CREATED AT #{base_path}"
    end

    def handle_render_for(rule)
      if rule.member
        render_member(rule)
      end

      if rule.collection
        render_collection(rule)
      end
    end

    def base_dir
    end

    def render_member(rule)
      return unless resource.respond_to?(:portability_member_for)
      o = resource.portability_member_for(rule)
      base_dir = self.base_path.join(rule.name)
      resource_path = base_dir.join("index.html")
      FileUtils.mkdir_p(base_dir)
      view = ExporterView.new({member: o}, {build_path: self.base_path, base_path: resource_path, template: rule.template, rule: rule})
      puts "saving at #{self.path.join rule.name}"
      view.save(resource_path )
    end

    def render_collection(rule)
      return unless resource.respond_to?(:portability_collection_for)
      o = resource.portability_collection_for(rule ,1)
      
      (1..o.total_pages).to_a.each do |i| 
        o = resource.portability_collection_for(rule,i)
        page_name = i #== 1 ? "index" : i
        base_dir  = self.base_path.join(rule.name)
        base_dir  = base_dir.join(page_name.to_s) unless page_name == 1
        FileUtils.mkdir_p(base_dir)
        resource_path = base_dir.join("index.html")
        view = ExporterView.new({collection: o}, {build_path: self.base_path, base_path: resource_path, template: rule.template, rule: rule})
        puts "saving at #{self.path.join rule.name}"
        view.save( resource_path )
      end
    end

    def render_index
      resource_path = self.base_path.join("index.html")
      template = PolicyManager::Config.exporter.index_template
      view = ExporterView.new({collection: PolicyManager::Config.portability_rules}, 
        {build_path: self.base_path, base_path: resource_path, template: template})
      puts "saving at #{resource_path}"
      view.save( resource_path )
    end

    def generate_zip
      directory_to_zip = base_path.to_s
      output_file = zip_path.to_s
      zf = ZipGenerator.new(directory_to_zip, output_file)
      zf.write()
    end

  end
end