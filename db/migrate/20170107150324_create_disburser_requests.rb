class CreateDisburserRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :disburser_requests do |t|
      t.integer   :repository_id,                   null: false
      t.integer   :submitter_id,                    null: false
      t.string    :title,                           null: false
      t.string    :investigator,                    null: false
      t.string    :irb_number,                      null: false
      t.boolean   :feasibility,                     null: true
      t.text      :methods_justifications,          null: false
      t.text      :cohort_criteria,                 null: false
      t.text      :data_for_cohort,                 null: false
      t.string    :status,                          null: false
      t.string    :fulfillment_status,              null: false
      t.timestamps                                  null: false
    end
  end
end