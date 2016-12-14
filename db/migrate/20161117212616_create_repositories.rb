class CreateRepositories < ActiveRecord::Migration[5.0]
  def change
    create_table :repositories do |t|
      t.string    :name,            null: false
      t.boolean   :data,            null: true
      t.boolean   :specimens,       null: true
      t.timestamps                  null: false
    end
  end
end