class AddContentPublishedColumnstoRepositories < ActiveRecord::Migration[5.0]
  def change
    add_column :repositories, :general_content_published, :text
    add_column :repositories, :data_content_published, :text
    add_column :repositories, :specimen_content_published, :text
  end
end