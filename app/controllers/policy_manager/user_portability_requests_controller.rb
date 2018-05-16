require_dependency "policy_manager/application_controller"

module PolicyManager
  class UserPortabilityRequestsController < ApplicationController

    def index
      @user_portability_requests = current_user.portability_requests
                                               .order(created_at: :desc)
                                               .paginate(
                                                :page => params[:page], 
                                                :per_page => 10)
    end

    def create
      respond_to do |format|
       
          if current_user.can_request_portability?
            if current_user.portability_requests.create
              format.html{
                redirect_to user_portability_requests_path, notice: I18n.t("terms_app.user_portability_requests.index.created")
              }
              format.json{
                render json: {notice: I18n.t("terms_app.user_portability_requests.index.created")}
              }
            end
          else
            format.html{
              redirect_to user_portability_requests_path, notice: I18n.t("terms_app.user_portability_requests.index.has_pending")
            }
            format.json{
              render json: {notice: I18n.t("terms_app.user_portability_requests.index.has_pending")}, status: 422  
            }
          end
        
      end
    end

    #def destroy
    #  PortabilityRequest.find(params[:id]).destroy
    #  redirect_to user_portability_requests_url, notice: I18n.t("terms_app.portability_requests.index.destroyed")
    #end

  end
end
