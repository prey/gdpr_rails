module PolicyManager
  class ApplicationController < ActionController::Base
    include Doorman::Controller if defined? Doorman

    before_action :user_authenticated?
    before_action :set_language

    def allow_admins
      redirect_to pending_user_terms_path unless Config.is_admin?(current_user)
    end

    def doc
      require 'redcarpet'
      @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true,
                                                                   fenced_code_blocks: true)
      lines = File.open(PolicyManager::Engine.root.join('README.md')).readlines
      @html = @markdown.render(lines.join(''))
      render 'policy_manager/doc'
      # render inline: html, layout: "policy_manager/application"
    end

    def user_authenticated?
      return if current_user

      render file: 'policy_manager/401.erb',
             layout: 'policy_manager/blank',
             status: :unauthorized
    end

    def set_language
      I18n.locale = Config.user_language(current_user)
    end

    def current_user
      @_current_user ||= super || (Config.has_different_admin_user_resource? && admin_user)
    end

    def admin_user
      send("current_#{Config.admin_user_resource.name.underscore}")
    end

    protect_from_forgery with: :exception
  end
end
