namespace :maintenance do
  desc "Committee email reminder"
  task(committe_email_reminder: :environment) do |t, args|
    puts 'Time to send the remiders!'
    Repository.where(committee_email_reminder: true).each do |repository|
      repository.committee_members.each do |committee_member|
        repository.disburser_requests.by_status(DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW).by_vote_status(committee_member, DisburserRequest::DISBURSER_REQUEST_VOTE_STATUS_PENDING_MY_VOTE).each do |disburser_request|
          if disburser_request.committee_review_at.days_since(1) > DateTime.now
            DisburserRequestStatusMailer.committee_review_reminder(disburser_request, committee_member).deliver
          end
        end
      end
    end
  end
end