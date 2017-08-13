class AddStatusAtToDisburserRequestStatuses < ActiveRecord::Migration[5.0]
  def change
    add_column :disburser_request_statuses, :status_at, :datetime, null: true

    DisburserRequestStatus.all.each do |disburser_request_status|
      disburser_request_status.status_at = disburser_request_status.created_at
      disburser_request_status.save!
    end

    change_column_null(:disburser_request_statuses, :status_at, false)
  end
end