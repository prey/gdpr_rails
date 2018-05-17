module PolicyManager
  class ApplicationController < ActionController::Base

    if defined? Doorman
      include Doorman::Controller
    end

    before_action :user_authenticated?
    before_action :set_language

    def allow_admins
      return redirect_to root_path unless Config.is_admin?(current_user)
    end

    def doc
      require "redcarpet"
      @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, fenced_code_blocks: true)
      lines = File.open( PolicyManager::Engine.root.join("README.md")).readlines
      @html = @markdown.render(lines.join(""))
      render "policy_manager/doc"
      #render inline: html, layout: "policy_manager/application"
    end

    def user_authenticated?
      if !current_user
        render :file => "policy_manager/401.erb", 
        :layout => "policy_manager/blank", 
        :status => :unauthorized
      end
    end

    def set_language
      I18n.locale = Config.user_language(current_user)
    end

    def current_user
      @_current_user ||=  super || (Config.has_different_admin_user_resource? && admin_user)
    end

    def admin_user
      self.send("current_#{Config.admin_user_resource.name.underscore}")
    end

    protect_from_forgery with: :exception
  end
end
