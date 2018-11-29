class TaxonFrameworksController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  before_filter :curator_required, only: [:new, :create, :edit, :update, :destroy]
  before_filter :admin_required, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_taxon_framework
  
  layout "bootstrap"
  
  def new
    @rank_levels = prepare_rank_levels
    if ( taxon_id = params["taxon_id"] ).present?
      @taxon_framework = TaxonFramework.new( taxon_id: taxon_id )
    else
      @taxon_framework = TaxonFramework.new
    end
  end
  
  def edit
    @rank_levels = prepare_rank_levels
  end
  
  def create
    @taxon_framework = TaxonFramework.new( taxon_framework_params )
    @taxon_framework.user = current_user
    @taxon_framework.updater = current_user
    
    if !@taxon_framework.rank_level.nil? && !current_user.is_admin?
      flash[:notice] = "only admins can create taxon fameworks with coverage"
      @rank_levels = prepare_rank_levels
      render action: :new
      return
    end
    if @taxon_framework.save
      redirect_to taxonomy_details_for_taxon_path( @taxon_framework.taxon )
    else
      flash[:error] = @taxon_framework.errors.full_messages.to_sentence
      @rank_levels = prepare_rank_levels
      render action: :new
    end
  end
  
  def update
    if !@taxon_framework.rank_level.nil? && !current_user.is_admin?
      flash[:notice] = "only admins can create taxon fameworks with coverage"
      @rank_levels = prepare_rank_levels
      render action: :edit
      return
    end
    pars = taxon_framework_params.update( updater_id: current_user.id )
    if @taxon_framework.update_attributes(pars)
      redirect_to taxonomy_details_for_taxon_path( @taxon_framework.taxon )
    else
      @rank_levels = prepare_rank_levels
      render action: :edit
    end
  end
  
  def destroy
    @taxon_framework.destroy
    flash[:notice] = "taxon framework deleted"
    redirect_to taxonomy_details_for_taxon_path( @taxon_framework.taxon )
  end
  
  private
  
  def prepare_rank_levels
    rank_levels = Taxon::RANK_FOR_RANK_LEVEL.invert
  end
  
  def set_taxon_framework
    @taxon_framework = TaxonFramework.where( id: params[:id] ).includes(
            { taxon: [:taxon_names, :photos, :taxon_ranges_without_geom, :taxon_schemes] },
            :source
          ).first
  end
   
  def taxon_framework_params
    params.require( :taxon_framework ).
      permit( :description, :taxon_id, :rank_level, :complete, :source_id, source_attributes: [:id, :in_text, :citation, :url, :title, :user_id] )
  end
  
end