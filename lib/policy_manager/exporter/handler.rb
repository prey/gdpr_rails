require "fileutils"
require 'zip'

module PolicyManager
  class ExporterHandler
    attr_accessor :resource, :path, :after_zip

    def initialize(opts={})
      self.path = opts[:path]
      self.resource = if opts[:resource].is_a?(String)
        opts[:resource].constantize
      else
        opts[:resource]
      end
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
      after_zip.call(zip_path, resource) if after_zip.is_a?(Proc)
      clear!
    end

    def handle_zip_upload
      resource
      .portability_requests
      .find_by(state: "progress")
      .update(file_remote_url: zip_path)
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
      FileUtils.mkdir_p(base_dir)
      resource_path = base_dir.join("index.html")

      view = ExporterView.new({
        assigns: {member: o},
        build_path: self.base_path,
        base_path: resource_path,
        template: rule.template,
        rule: rule
      }).save(resource_path)

      puts "saving at #{self.path.join rule.name}"

      json = JsonExporterView.new(
        assigns: {member: o},
        template: rule.json_template,
        folder: base_dir
      ).save if rule.json_template.present?
    end

    def render_collection(rule)
      return unless resource.respond_to?(:portability_collection_for)
      o = resource.portability_collection_for(rule, 1)

      base_dir  = self.base_path.join(rule.name)
      FileUtils.mkdir_p(base_dir)

      (1..o.total_pages).to_a.each do |i|
        o = resource.portability_collection_for(rule, i)

        page_name = i
        folder_dir = page_name == 1 ? base_dir : base_dir.join(page_name.to_s)
        FileUtils.mkdir_p(folder_dir)
        resource_path = folder_dir.join("index.html")

        view = ExporterView.new({
          assigns: {collection: o} ,
          build_path: self.base_path,
          base_path: resource_path,
          template: rule.template,
          rule: rule
        }).save(resource_path)


        json = JsonExporterView.new(
          assigns: {collection: o},
          template: rule.json_template,
          folder: folder_dir
        ).save if rule.json_template.present?

        puts "saving at #{self.path.join rule.name}"
      end
    end

    def render_index
      resource_path = self.base_path.join("index.html")
      template = PolicyManager::Config.exporter.index_template
      view = ExporterView.new({
        assigns: {
          collection: PolicyManager::Config.portability_rules
        },
        build_path: self.base_path,
        base_path: resource_path,
        template: template
      }).save( resource_path )
      puts "saving at #{resource_path}"
    end

    def generate_zip
      directory_to_zip = base_path.to_s
      output_file = zip_path.to_s
      zf = ZipGenerator.new(directory_to_zip, output_file)
      zf.write()
    end

  end
end
