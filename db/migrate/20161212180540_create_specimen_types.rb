class CreateSpecimenTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :specimen_types do |t|
      t.integer   :repository_id,       null: false
      t.string    :name,                null: false
      t.timestamps                      null: false
    end
  end
end
