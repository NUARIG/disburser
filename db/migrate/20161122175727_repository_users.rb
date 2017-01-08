class RepositoryUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :repository_users do |t|
      t.integer   :repository_id,       null: false
      t.integer   :user_id,             null: false
      t.boolean   :administrator,       null: true
      t.boolean   :committee,           null: true
      t.boolean   :specimen_resource,   null: true
      t.boolean   :data_resource,       null: true
      t.timestamps                      null: false
    end
  end
end
