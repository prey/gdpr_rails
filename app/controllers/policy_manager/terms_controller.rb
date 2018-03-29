require_dependency "terms/application_controller"

module PolicyManager
  class TermsController < ApplicationController
    before_action :set_term, only: [:show, :edit, :update, :destroy]

    # GET /terms
    def index
      @terms = Term.all
    end

    # GET /terms/1
    def show
    end

    # GET /terms/new
    def new
      @term = Term.new
    end

    # GET /terms/1/edit
    def edit
    end

    # POST /terms
    def create
      @term = Term.new(term_params)

      if @term.save
        redirect_to category_term_path(@term.category, @term), notice: 'Term was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /terms/1
    def update
      if @term.update(term_params)
        redirect_to category_term_path(@term.category, @term), notice: 'Term was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /terms/1
    def destroy
      @term.destroy
      redirect_to category_terms_path(@term.category), notice: 'Term was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_term
        @term = Term.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def term_params
        params.require(:term).permit(:description, :category_id)
      end
  end
end
