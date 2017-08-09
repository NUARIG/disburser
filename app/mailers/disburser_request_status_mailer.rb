class DisburserRequestStatusMailer < ApplicationMailer
  default from: Rails.configuration.custom.app_config['support']['sender_address']

  def status_submittted(disburser_request)
    @disburser_request = disburser_request
    subject = prepare_subject('Disbursement Request Submittted')
    to = []
    cc = []
    to << disburser_request.submitter.email

    mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
  end

  def status_submittted_data_coordinator(disburser_request)
    @disburser_request = disburser_request
    subject = prepare_subject('Disbursement Request Submittted for Data Coordinator')
    to = []
    cc = []

    if disburser_request.repository.data_coordinators.any?
      to.concat(disburser_request.repository.data_coordinators.map(&:email))
    end

    if to.any?
      mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
    end
  end

  def status_submittted_specimen_coordinator(disburser_request)
    @disburser_request = disburser_request
    subject = prepare_subject('Disbursement Request Submittted for Specimen Coordinator')
    to = []
    cc = []

    if disburser_request.specimens? && disburser_request.repository.specimen_coordinators.any?
      to.concat(disburser_request.repository.specimen_coordinators.map(&:email))
    end

    if to.any?
      mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
    end
  end

  def status_submittted_administrator(disburser_request)
    @disburser_request = disburser_request
    subject = prepare_subject('Disbursement Request Submittted for Administrator')
    to = []
    cc = []

    if disburser_request.repository.repository_administrators.any?
      to = disburser_request.repository.repository_administrators.map(&:email)
    end

    if to.any?
      mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
    end
  end

  def committee_review_reminder(disburser_request, user)
    @disburser_request = disburser_request
    subject = prepare_subject('Committee Review for Disbursement Request Reminder')
    to = []
    cc = []

    to << user.email

    if to.any?
      mail(to: user.email, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
    end
  end

  def status_committee_review(disburser_request)
    @disburser_request = disburser_request
    subject = prepare_subject('Committee Review for Disbursement Request')
    to = []
    cc = []

    if disburser_request.repository.committee_members.any?
      to = disburser_request.repository.committee_members.map(&:email)
    end

    if disburser_request.repository.notify_repository_administrator && disburser_request.repository.repository_administrators.any?
      cc = disburser_request.repository.repository_administrators.map(&:email)
    end

    if to.any?
      mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
    end
  end

  def status_approved(disburser_request)
    @disburser_request = disburser_request
    subject = prepare_subject('Disbursement Request Approved')
    to = []
    cc = []
    to << disburser_request.submitter.email

    if disburser_request.repository.notify_repository_administrator && disburser_request.repository.repository_administrators.any?
      cc = disburser_request.repository.repository_administrators.map(&:email)
    end

    mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
  end

  def status_approved_data_coordinator(disburser_request)
    @disburser_request = disburser_request
    subject = prepare_subject('Disbursement Request Approved for Data Coordinator')
    to = []
    cc = []

    if disburser_request.repository.data_coordinators.any?
      to.concat(disburser_request.repository.data_coordinators.map(&:email))
    end

    if to.any?
      mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
    end
  end

  def status_approved_specimen_coordinator(disburser_request)
    if disburser_request.specimens?
      @disburser_request = disburser_request
      subject = prepare_subject('Disbursement Request Approved for Specimen Coordinator')
      to = []
      cc = []

      if disburser_request.specimens? && disburser_request.repository.specimen_coordinators.any?
        to.concat(disburser_request.repository.specimen_coordinators.map(&:email))
      end

      if to.any?
        mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
      end
    end
  end

  def status_denied(disburser_request)
    @disburser_request = disburser_request
    subject = prepare_subject('Disbursement Request Denied')
    to = []
    cc = []
    to << disburser_request.submitter.email

    if disburser_request.repository.notify_repository_administrator && disburser_request.repository.repository_administrators.any?
      cc = disburser_request.repository.repository_administrators.map(&:email)
    end

    mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
  end

  def status_canceled(disburser_request)
    @disburser_request = disburser_request
    subject = prepare_subject('Disbursement Request Canceled')
    to = []
    cc = []
    to << disburser_request.submitter.email

    if disburser_request.repository.notify_repository_administrator && disburser_request.repository.repository_administrators.any?
      cc = disburser_request.repository.repository_administrators.map(&:email)
    end

    mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
  end

  def data_status_data_checked_specimen_coordinator(disburser_request)
    if disburser_request.specimens?
      @disburser_request = disburser_request
      subject = prepare_subject('Data Checked for Disbursement Request')
      to = []
      cc = []

      if disburser_request.repository.specimen_coordinators.any?
        to.concat(disburser_request.repository.specimen_coordinators.map(&:email))
      end

      if to.any?
        mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
      end
    end
  end

  def data_status_data_checked_administrator(disburser_request)
    @disburser_request = disburser_request
    subject = prepare_subject('Data Checked for Disbursement Request')
    to = []
    cc = []

    if disburser_request.repository.repository_administrators.any?
      to = disburser_request.repository.repository_administrators.map(&:email)
    end

    if to.any?
      mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
    end
  end

  def data_status_insufficient_data(disburser_request)
    @disburser_request = disburser_request
    subject = prepare_subject('Insufficient Data for Disbursement Request')
    to = []
    cc = []
    to << disburser_request.submitter.email

    if disburser_request.repository.notify_repository_administrator && disburser_request.repository.repository_administrators.any?
      cc = disburser_request.repository.repository_administrators.map(&:email)
    end

    if to.any?
      mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
    end
  end

  def data_status_query_fulfilled_administrator(disburser_request)
    @disburser_request = disburser_request
    subject = prepare_subject('Query Fulfilled for Disbursement Request')
    to = []
    cc = []

    if disburser_request.repository.repository_administrators.any?
      to = disburser_request.repository.repository_administrators.map(&:email)
    end

    if to.any?
      mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
    end
  end

  def specimen_status_inventory_checked(disburser_request)
    @disburser_request = disburser_request
    subject = prepare_subject('Inventory Checked for Disbursement Request')
    to = []
    cc = []

    if disburser_request.repository.repository_administrators.any?
      to = disburser_request.repository.repository_administrators.map(&:email)
    end

    if to.any?
      mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
    end
  end

  def specimen_status_insufficient_specimens(disburser_request)
    @disburser_request = disburser_request
    subject = prepare_subject('Insufficient Specimens for Disbursement Request')
    to = []
    cc = []
    to << disburser_request.submitter.email

    if disburser_request.repository.repository_administrators.any?
      cc = disburser_request.repository.repository_administrators.map(&:email)
    end

    if to.any?
      mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
    end
  end

  def specimen_status_inventory_fulfilled(disburser_request)
    @disburser_request = disburser_request
    subject = prepare_subject('Inventory Fulfilled for Disbursement Request')
    to = []
    cc = []

    if disburser_request.repository.repository_administrators.any?
      to = disburser_request.repository.repository_administrators.map(&:email)
    end

    if to.any?
      mail(to: to, cc: cc, from: Rails.configuration.custom.app_config['support']['sender_address'], subject: subject)
    end
  end

  def prepare_subject(subject)
    if Rails.env.development? || Rails.env.staging?
      subject = "[#{Rails.env}] #{subject}"
    end
    subject
  end
end