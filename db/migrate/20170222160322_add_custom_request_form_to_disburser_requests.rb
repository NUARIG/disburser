class AddCustomRequestFormToDisburserRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :disburser_requests, :use_custom_request_form, :boolean
    add_column :disburser_requests, :custom_request_form, :text
  end
end
