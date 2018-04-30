require_dependency "policy_manager/application_controller"
module PolicyManager
  class PortabilityRequestsController < ApplicationController
    
    before_action :set_portability_request, only: :destroy
    before_action :allow_admins

    # GET /portability_requests
    def index
      @portability_requests = PortabilityRequest.order(created_at: :desc).paginate(:page => params[:page], :per_page => 10)
    end

    def confirm
      @portability_request = PortabilityRequest.find(params[:id])
      if @portability_request.confirm!
        redirect_to portability_requests_path
      end
    end

    # DELETE /portability_requests/1
    def destroy
      @portability_request.destroy
      redirect_to portability_requests_url, notice: I18n.t("terms_app.portability_requests.index.destroyed")
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_portability_request
      @portability_request = PortabilityRequest.find(params[:id])
    end

  end
end
