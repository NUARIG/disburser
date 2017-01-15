class CreateDisburserRequestStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :disburser_request_statuses do |t|
      t.integer   :disburser_request_id,                   null: false
      t.string    :status,                                 null: false
      t.string    :username,                               null: false
      t.timestamps                                         null: false
    end
  end
end