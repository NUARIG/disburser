class AddPublicToRepositories < ActiveRecord::Migration[5.0]
  def change
    add_column :repositories, :public, :boolean
  end
end
