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

    def user_authenticated?
      if !current_user
        render :file => "401.erb", :layout => false, :status => :unauthorized
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
