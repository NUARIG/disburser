class AddAndRenameStatusColumnsFromDisburserRequests < ActiveRecord::Migration[5.0]
  def change
    rename_column :disburser_requests, :fulfillment_status, :data_status
    add_column :disburser_requests, :specimen_status, :string
  end
end
