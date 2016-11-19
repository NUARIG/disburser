class CreateRepositories < ActiveRecord::Migration[5.0]
  def change
    create_table :repositories do |t|
      t.string    :name,            null: false
      t.boolean   :data,            null: false
      t.boolean   :specimens,       null: false
      t.timestamps                  null: false
    end
  end
end