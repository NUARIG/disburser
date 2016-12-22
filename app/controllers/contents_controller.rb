class ContentsController < ApplicationController
  before_action :load_repository, only: [:edit, :update]

  def edit
  end

  def update
    if @repository.update_attributes(repository_params)
      redirect_to edit_repository_content_url(@repository)
    else
      flash.now[:alert] = 'Failed to update repository content.'
      render action: 'edit'
    end
  end

  private
    def repository_params
      params.require(:repository).permit(:data_content, :specimen_content)
    end

    def load_repository
      @repository = Repository.find(params[:repository_id])
    end
end