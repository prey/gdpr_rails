require_dependency "terms/application_controller"

require "request_store"

module PolicyManager
  class UserTermsController < ApplicationController
    before_action :set_user_term, only: [:accept, :reject, :show, :edit, :update, :destroy]

    if defined? Doorman
      include Doorman::Controller
    end

    # GET /user_terms
    def index
      @user_terms = UserTerm.all
    end

    # GET /user_terms/1
    def show
      @user_term = current_user.handle_policy_for(@term)
    end

    def pending
      @pending_policies = current_user.pending_policies
      respond_to do |format|
        format.html{ }
        format.json{ render json: @pending_policies }
      end
    end

    def accept
      @user_term = current_user.handle_policy_for(@term)
      @user_term.accept!
      respond_to do |format|
        format.html{ 
          if @user_term.errors.any?
            redirect_to root_url , notice: "hey there are some errors! #{@user_term.errors.full_messages.join()}"
          else
            redirect_to root_url 
          end
        }
        format.js
        format.json
      end
    end

    def reject
      @user_term = current_user.handle_policy_for(term: @term)
      @user_term.reject!
      respond_to do |format|
        format.html{ 
          if @user_term.errors.any?
            redirect_to root_url , notice: "hey there are some errors! #{@user_term.errors.full_messages.join()}"
          else
            redirect_to root_url 
          end
        }
        format.js
        format.json{

          if @user_term.errors.any?
            render :json, url: root_url , notice: "hey there are some errors! #{@user_term.errors.full_messages.join()}"
          else
            render :json, url: root_url 
          end

        }
      end
    end

    # GET /user_terms/new
    def new
      @user_term = UserTerm.new
    end

    # GET /user_terms/1/edit
    def edit
    end

    # POST /user_terms
    def create
      @user_term = UserTerm.new(user_term_params)

      if @user_term.save
        redirect_to @user_term, notice: 'User term was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /user_terms/1
    def update
      if @user_term.update(user_term_params)
        redirect_to @user_term, notice: 'User term was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /user_terms/1
    def destroy
      @user_term.destroy
      redirect_to user_terms_url, notice: 'User term was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_user_term
        @category = Category.find(params[:id])
        @term = @category.terms.last
        #@term = Term.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def user_term_params
        params.fetch(:user_term, {})
      end
  end
end
