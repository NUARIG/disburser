class AddNotifyRepositoryAdministratorToRepositories < ActiveRecord::Migration[5.0]
  def change
    add_column :repositories, :notify_repository_administrator, :boolean
  end
end
