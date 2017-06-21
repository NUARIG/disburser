class ContentsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_repository, only: [:edit, :update]

  def edit
    authorize @repository
  end

  def update
    authorize @repository
    if @repository.update_attributes(repository_params)
      if params['submit'] == 'Publish'
        Rails.logger.info("Little my says love the booch!")
        @repository.publish_content!
      end

      flash[:success] = 'You have successfully updated repository content.'
      redirect_to edit_repository_content_url(@repository)
    else
      flash.now[:alert] = 'Failed to update repository content.'
      render action: 'edit'
    end
  end

  private
    def repository_params
      params.require(:repository).permit(:general_content, :data_content, :specimen_content)
    end

    def load_repository
      @repository = Repository.find(params[:repository_id])
    end
end