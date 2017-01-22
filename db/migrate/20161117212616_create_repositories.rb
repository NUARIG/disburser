class CreateRepositories < ActiveRecord::Migration[5.0]
  def change
    create_table :repositories do |t|
      t.string    :name,              null: false
      t.string    :irb_template,      null: true
      t.string    :data_dictionary,   null: true
      t.text      :general_content,   null: true
      t.text      :data_content,      null: true
      t.text      :specimen_content,  null: true
      t.timestamps                    null: false
    end
  end
end