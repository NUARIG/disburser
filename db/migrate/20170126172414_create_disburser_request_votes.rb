class CreateDisburserRequestVotes < ActiveRecord::Migration[5.0]
  def change
    create_table :disburser_request_votes do |t|
      t.integer   :disburser_request_id,                   null: false
      t.integer   :committee_member_user_id,               null: false
      t.string    :vote,                                   null: false
      t.text      :comments,                               null: true
      t.timestamps                                         null: false
    end
  end
end



