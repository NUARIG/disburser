class AddSupportingDocumentToDisburserRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :disburser_requests, :supporting_document, :text
  end
end