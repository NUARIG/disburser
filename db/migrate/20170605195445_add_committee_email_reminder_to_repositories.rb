class AddCommitteeEmailReminderToRepositories < ActiveRecord::Migration[5.0]
  def change
    add_column :repositories, :committee_email_reminder, :boolean
  end
end
