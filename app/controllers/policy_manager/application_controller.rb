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
        render :file => "public/401.html", :layout => false, :status => :unauthorized
      end
    end

    def set_language
      I18n.locale = Config.user_language(current_user)
    end

    def current_user
      @_current_user ||=  super || Config.current_admin_user_method&.call(self)
    end

    protect_from_forgery with: :exception
  end
end
