class AddSpecimenQuantityAndSpecimenNameToDisburserRequestStatus < ActiveRecord::Migration[5.0]
  def change
    add_column :disburser_request_statuses, :specimen_quantity, :integer, null: true
    add_reference :disburser_request_statuses, :specimen_type, index: true, null: true
  end
end
