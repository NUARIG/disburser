class AddCustomRequestFormToRepositories < ActiveRecord::Migration[5.0]
  def change
    add_column :repositories, :custom_request_form, :text
  end
end
