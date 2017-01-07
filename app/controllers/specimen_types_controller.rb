class SpecimenTypesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_repository, only: [:index, :bulk_update]

  def index
    authorize SpecimenType.new(repository: @repository)
  end

  def bulk_update
    authorize SpecimenType.new(repository: @repository)
    if @repository.update_attributes(repository_params)
      flash[:success] = 'You have successfully updated specimen types.'
      redirect_to repository_specimen_types_url(@repository)
    else
      flash.now[:alert] = 'Failed to update specimen types.'
      render 'specimen_types/index'
    end
  end

  private
    def repository_params
      params.require(:repository).permit(:name, :data, :specimens, specimen_types_attributes: [:id, :name, :volume, :_destroy])
    end

    def load_repository
      @repository = Repository.find(params[:repository_id])
    end
end