class CreateDisburserRequestDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :disburser_request_details do |t|
      t.integer   :disburser_request_id,                   null: false
      t.integer   :specimen_type_id,                       null: false
      t.integer   :quantity,                               null: false
      t.string    :volume,                                 null: true
      t.text      :comments,                               null: true
      t.timestamps                                         null: false
    end
  end
end