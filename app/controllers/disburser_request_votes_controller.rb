class DisburserRequestVotesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_disburser_request, only: [:create, :update]
  before_action :load_disburser_request_vote, only: :update

  def create
    @disburser_request_vote = @disburser_request.disburser_request_votes.build(disburser_vote_params)
    authorize @disburser_request_vote
    @disburser_request_vote.committee_member = current_user

    if @disburser_request_vote.save
      flash[:success] = 'You have successfully voted a for a repository request.'
      redirect_to committee_disburser_requests_url
    else
      flash.now[:alert] = 'Failed to vote for a repository request.'
      render template: '/disburser_requests/edit_committee_review'
    end
  end

  def update
    authorize @disburser_request_vote
    if @disburser_request_vote.update_attributes(disburser_vote_params)
      flash[:success] = 'You have successfully updated a repository request vote.'
      redirect_to committee_disburser_requests_url
    else
      flash.now[:alert] = 'Failed to update repository request vote.'
      render template: '/disburser_requests/edit_committee_review'
    end
  end

  private
    def disburser_vote_params
      params.require(:disburser_request_vote).permit(:vote, :comments)
    end

    def load_disburser_request
      @disburser_request = DisburserRequest.find(params[:disburser_request_id])
    end

    def load_disburser_request_vote
      @disburser_request_vote = DisburserRequestVote.find(params[:id])
    end
end